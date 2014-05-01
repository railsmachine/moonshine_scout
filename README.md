# Moonshine Scout

A [Moonshine](http://github.com/railsmachine/moonshine) plugin for installing
and managing the [Scout](http://scoutapp.com) [client](http://github.com/highgroove/scout-client).

# Requirements

* A [Scout](http://scoutapp.com) account
* The agent key for your server. This key will be provided at the time you add
your server to Scout, and is also available under the Server Admin section of
the site.

# Quickstart Instructions

* @script/plugin install git://github.com/railsmachine/moonshine_scout.git@
* Configure agent key in @config/moonshine.yml@
  <pre>
    :scout:
      :agent_key: YOUR-PRIVATE-SCOUT-KEY
  </pre>
* Include the plugin and recipe(s) in your Moonshine manifest
  <pre>
    recipe :scout
  </pre>

Scout is now configured to run via cron every 3 minutes.

# Advanced configuration

You can adjust the <tt>user</tt> that runs the Scout command and the <tt>interval</tt> at
which it runs by using the respective keys:

<pre>
  :scout:
    :agent_key: YOUR-PRIVATE-SCOUT-KEY
    :interval:  15 # defaults to 3
    :user:      root # defaults to the moonshine user, or 'daemon' if that's not configured
</pre>

To use [private plugins](https://scoutapp.com/info/creating_a_plugin#private_plugins), you'll need to configure a scout_rsa.pub. Follow the [instruction](https://scoutapp.com/info/creating_a_plugin#private_plugins) and copy the <tt>scout_rsa.pub</tt> to <tt>app/manifests/templates</tt>.

***
Unless otherwise specified, all content copyright &copy; 2014, [Rails Machine, LLC](http://railsmachine.com)
