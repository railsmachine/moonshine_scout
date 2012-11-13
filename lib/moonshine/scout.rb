# **Moonshine::Scout** is a Moonshine plugin for installing and configuring
# a server to check into [Scout](scoutapp).

#### Prerequisites

# * A [Scout](scoutapp) account
# * The agent key for your server. This key will be provided at the time you add your server to Scout, and is also available under the Server Admin section of the site.
#
# [scoutapp]: http://scoutapp.com
module Moonshine
  module Scout

    #### Recipe
    #
    # We define the `:scout` recipe which can take inline options.
    #
    def scout(options = {})

      # For convenience, we normalize the user scout will be running under.If nothing else, this will default to daemon.
      user = options[:user] || configuration[:user] || 'daemon'
      agent_key = options[:agent_key] || configuration[:scout][:agent_key]

      # The only required option is :agent_key. We won't fail the deploy over it though, so just return instead.
      unless agent_key
        puts "To use the Scout agent, specify your key in config/moonshine.yml:"
        puts ":scout:"
        puts "  :agent_key: YOUR-SCOUT-KEY"
        return
      end

      # First, install the scout gem. We want at least 5.3.3 for private plugin support.
      gem 'scout', :ensure => '>= 5.3.3'

      # Then, we need it to run regularly through cron.
      # This can be configured with:
      #
      # * `:interval`: defaults to every minute
      cron 'scout_checkin',
        :command  => "/usr/bin/scout #{agent_key}",
        :minute   => "*/#{options[:interval]||1}",
        :user     => user

      # Scout allows you to create your own [private plugins](https://scoutapp.com/info/creating_a_plugin#private_plugins). This requires some additional setup.
      # 
      # The user checking into scout needs to have a ~/.scout/scout_rsa.pub file present to be able to use private plugins.
      #
      # moonshine_scout manages this by checking app/manifests/scout_rsa.pub, and setting it up on the server if it's around
      scout_rsa_pub = local_template(Pathname.new('scout_rsa.pub'))
      if scout_rsa_pub.exist?
        file "/home/#{user}/.scout",
          :alias => '.scout',
          :ensure => :directory,
          :owner => user

        file "/home/#{user}/.scout/scout_rsa.pub",
          :ensure => :present,
          :content => template(scout_rsa_pub),
          :require => file('.scout'),
          :owner => user
      end


      # At this point, we have enough installed to be able to check into scout. However, some plugins require additional gems and packages be installed
      # The Apache Status plugin calls apache2ctl status, which
      # requires lynx
      package 'lynx', :ensure => :installed, :before => package('scout')
      # This can leave tempfiles around in /tmp though, so we setup a 
      # cronjob to clear it out
      cron 'cleanup_lynx_tempfiles',
        :command  => "find /tmp/ -name 'lynx*' -type d -delete",
        :hour     => '0',
        :minute   => '0'

      # Some cool plugins need the sysstat package, which installs things like iostat, mpstat, and other friends:
      #
      #  * [Device Input/Output (iostat)](https://scoutapp.com/plugin_urls/161-device-inputoutput-iostat)
      #  * [Processor statistics (mpstat)](https://scoutapp.com/plugin_urls/331-processor-statistics-mpstat)
      package 'sysstat', :ensure => :installed, :before => package('scout')

      # The moonshine user needs to be part of the adm group for a few plugins. Usually, it's for accessing logs:
      #
      # * [MySQL Slow Queries](https://scoutapp.com/plugin_urls/21-mysql-slow-queries)
      # * [Apache Log Analyzer](https://scoutapp.com/plugin_urls/201-apache-log-analyzer)
      # needed for MySQL Slow Queries to work
      # add user to adm group, to be able to acces
      # FIXME this seems to run EVERY time, regarless of the unless
      exec "usermod -a -G adm #{configuration[:user]}",
        :unless => "groups #{configuration[:user]} | egrep '\\badm\\b'", # this could probably be more succintly and strongly specfied
        :before => package('scout')

      # [Ruby on Rails Monitoring](https://scoutapp.com/plugin_urls/181-ruby-on-rails-monitoring) depends on a few gems to be installed
      gem 'elif', :before => package('scout')
      gem 'request-log-analyzer', :ensure => :latest, :before => package('scout')

      # Lastly, we need to make sure the old scout_agent service isn't running.
      file '/etc/init.d/scout_agent',
        :content => template(File.join(File.dirname(__FILE__), 'scout', 'templates', 'scout_agent.init.erb'), binding),
        :mode    => '744'

      service 'scout_agent',
        :enable  => false,
        :ensure  => :stopped,
        :require => file('/etc/init.d/scout_agent')
    end

  end
end
