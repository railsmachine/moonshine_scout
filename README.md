#Moonshine Scout
==============================

A [Moonshine][] plugin for installing\
and managing the [Scout][] [client][].

### Requirements

-   A [Scout][] account
-   The agent key for your server. This key will be provided at the time
    you add\
    your server to Scout, and is also available under the Server Admin
    section of\
    the site.

### Quickstart Instructions

-   `script/plugin install git://github.com/railsmachine/moonshine_scout.git`
-   Configure agent key in `config/moonshine.yml`\
     \<pre\>\
     :scout:\
     :agent\_key: YOUR-PRIVATE-SCOUT-KEY\
     \</pre\>
-   Include the plugin and recipe(s) in your Moonshine manifest\
     \<pre\>\
     recipe :scout\
     \</pre\>

Scout is now configured to run via cron every 3 minutes.

### Advanced configuration

You can adjust the `user` that runs the Scout command and the `interval`
at\
which it runs by using the respective keys:

      :scout:
        :agent_key: YOUR-PRIVATE-SCOUT-KEY
        :interval:  15 # defaults to 3
        :user:      root # defaults to the moonshine user, or 'daemon' if that's not configured

#### Scout Realtime Gem

You can enable the scout realtime gem by setting :realtime: true in your
manifest. You can also run the cap tasks below by adding the following
options in your environment yaml. If you do not set these variables,
they will default to the values below. (with the exception of :realtime:
which must be set to TRUE to enable scout\_realtime )

      :scout:
        :realtime: TRUE   #
        :version:  INT    # defaults to 0.5.3
        :port:     INT    # defaults to 5555
        :log:      PATH   # defaults to ~/.scout/scout_realtime.log
        :pid:      PATH   # defaults to ~/scout/scout_realtime.pid

Cap Tasks : 
[cap scout:realtime:start]   # Starts the scout_realtime daemon
[cap scout:realtime:stop]   #  Stops the scout_realtime daemon
[cap scout:realtime:foreground]    # Runs in the foreground, and does not daemonize the process.
[cap scout:realtime:open_firewall_port]  # Adds an iptables rule allowing traffic on the port selected in the yaml file.
[cap scout:realtime:close_firewall_port] # Removes the iptables rule for the selected port.
[cap scout:realtime:open_web]   #  Opens the realtime web interface locally.
[cap scout:realtime:start_ssh_tunnel]    #  Starts an SSH tunnel for the 

To use [private plugins][], you’ll need to configure a scout\_rsa.pub.
Follow [the instruction][private plugins] and copy the `scout_rsa.pub`
to `app/manifests/templates`.

  [Moonshine]: http://github.com/railsmachine/moonshine
  [Scout]: http://scoutapp.com
  [client]: http://github.com/highgroove/scout-client
  [private plugins]: https://scoutapp.com/info/creating_a_plugin#private_plugins
