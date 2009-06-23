module Scout

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:scout => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :scout
  #  recipe :scout
  def scout(options = {})
    
    unless options[:agent_key]
      puts "To use the Scout agent, specify your key in the application manifest:"
      puts "  configure( :scout => { :agent_key => 'YOUR-PRIVATE-SCOUT-KEY'} )"
      return
    end
    
    # provides iostat, needed for disk i/o plugin
    package 'sysstat', :ensure => :installed
    
    # normally we'd use "gem 'scout_agent", but we need to send a notification here
    package 'scout_agent', :provider => :gem, :ensure => :installed, :notify => exec('identify_scout')

    exec 'identify_scout',
      :refreshonly => true,
      :before => file('/etc/scout_agent.rb'),
      :cwd => '/tmp',
      :command => ["echo #{options[:agent_key]} > scout.key",
                   "scout_agent identify scout.key",
                   "rm scout.key"].join(' && ')

    file '/etc/scout_agent.rb',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'scout_agent.rb.erb'), binding),
      :mode    => '744',
      :require => package('scout_agent'),
      :notify  => service('scout_agent')
    
    file '/etc/init.d/scout_agent',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'scout_agent.init.erb'), binding),
      :mode    => '744',
      :require => file('/etc/scout_agent.rb')
    
    service 'scout_agent',
      :enable  => true,
      :ensure  => :running,
      :require => file('/etc/init.d/scout_agent')
  end
  
end