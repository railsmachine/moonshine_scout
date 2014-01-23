before 'scout:realtime', 'moonshine:configure_stage'
before 'scout:realtime', 'moonshine:configure'

namespace :scout do 
  namespace :realtime do
    
    desc "[internal] set vars"
    task :set_vars do
        @scout = fetch(:scout)
        @realtime = @scout[:realtime] || {}
        @realtime[:port] ||= "5555"
        @realtime[:pid] ||= "~/.scout/scout_realtime.pid"
        @realtime[:log] ||= "~/.scout/scout_realtime.log"
        end
    
    desc "Start scout_realtime daemon"
    task :start do
      set_vars
      run "scout_realtime start -p #{@realtime[:port]} -l #{@realtime[:log]} -i #{@realtime[:pid]}"  
    end 
    
    desc "Stop scout_realtime daemon"
    task :stop do
      run "scout_realtime stop"
    end
    
    desc "Start scout_realtime foreground"
    task :foreground do
      set_vars
      run "scout_realtime start -p #{@realtime[:port]} -l #{@realtime[:log]} -i #{@realtime[:pid]} -f"
    end
    
    desc "Open scout_realtime firewall port"
    task :open_firewall_port do
      set_vars
      sudo "iptables -A INPUT -p tcp --dport #{@realtime[:port]} -j ACCEPT"
    end
    
    desc "Close scout_realtime firewall port"
    task :close_firewall_port do
      set_vars
      sudo "iptables -D INPUT -p tcp --dport #{@realtime[:port]} -j ACCEPT"
    end
    
    desc "Start scout_realtime SSH tunnel"
    task :start_ssh_tunnel do
      set_vars
      run_locally "ssh -NL #{@realtime[:port]}:localhost:#{@realtime[:port]} #{fetch(:user)}@$CAPISTRANO:HOST$"
    end
    
    desc "Open scout_realtime web interface"
    task :open_web do
      set_vars
      start_ssh_tunnel
      run_locally "open http://localhost:#{@realtime[:port]}"
    end
       
  end
end
