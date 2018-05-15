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
      realtime = options[:realtime] || configuration[:scout][:realtime] || false

      # The only required option is :agent_key. We won't fail the deploy over it though, so just return instead.
      unless agent_key
        puts "To use the Scout agent, specify your key in config/moonshine.yml:"
        puts ":scout:"
        puts "  :agent_key: YOUR-SCOUT-KEY"
        return
      end

      if realtime
        scout_realtime(options, version)
      else
        scoutd(options, user, agent_key)
      end
    end

    def scout_realtime(options, realtime)
      # First, install the scout gem.
      gem 'scout', :ensure => (options[:version] || :latest)

      # If Scout Realtime is wanted, install gem.
      gem 'scout_realtime', :ensure => (realtime[:version] || :latest) if realtime
    end

    def scoutd(options, user, agent_key)
      exec 'add scout apt key',
        :command => 'wget -q -O - https://archive.server.pingdom.com/scout-archive.key | sudo apt-key add -',
        :unless => "sudo apt-key list | grep 'Scout Packages (archive.scoutapp.com) <support@scoutapp.com>'",
        :require => package('python-software-properties')

      repo_path = "deb http://archive.server.pingdom.com ubuntu main"

      file '/etc/apt/sources.list.d/scout.list',
        :content => repo_path,
        :require => exec('add scout apt key')

      exec 'scout apt-get update',
        :command => 'sudo apt-get update',
        :require => file('/etc/apt/sources.list.d/scout.list')

      package 'scoutd',
        :ensure => :latest,
        :require => exec('scout apt-get update')

      gem 'scout', :ensure => :purged

      cron 'scout_checkin',
        :command  => "/usr/bin/scout #{agent_key}",
        :ensure   => :absent,
        :user     => user

      exec 'copy scout config directory',
        :command => "sudo cp -r /home/#{configuration[:user]}/.scout/* /var/lib/scoutd/ && sudo chown -R scoutd:scoutd /var/lib/scoutd",
        :subscribe => package('scoutd'),
        :require => package('scoutd'),
        :onlyif => "test -d /home/#{configuration[:user]}/.scout/",
        :refreshonly => true

      file '/etc/scout/scoutd.yml',
        :content => template(File.join(File.dirname(__FILE__), 'scout', 'templates', 'scoutd.yml.erb'), binding),
        :owner => 'scoutd',
        :group => 'scoutd',
        :mode => '640',
        :require => package('scoutd'),
        :notify => service('scout')

      exec 'scoutd add sudoers includedir',
        :command => [
          "cp /etc/sudoers /tmp/sudoers",
          "echo '#includedir /etc/sudoers.d' >> /tmp/sudoers",
          "visudo -c -f /tmp/sudoers",
          "cp /tmp/sudoers /etc/sudoers",
          "rm -f /tmp/sudoers"
        ].join(' && '),
        :unless => "grep '#includedir /etc/sudoers.d' /etc/sudoers"

      file '/etc/sudoers.d/scoutd',
        :content => template(File.join(File.dirname(__FILE__), 'scout', 'templates', 'scoutd.sudoers.erb'), binding),
        :owner => 'root',
        :group => 'root',
        :mode => '440',
        :require => [package('scoutd'), exec('scoutd add sudoers includedir')]

      service 'scout',
        :ensure => :running,
        :require => package('scoutd'),
        :enable => true
    end
  end
end
