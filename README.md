#Overview

The Robby module manages the deployment of the [Robby application](https://github.com/puppetlabs/OfficeMap)

#Module Description

The Robby application is an internal office and person directory.  This module
deploys the application from github and manages the unicorn based service that
provides a socket located at **/var/run/robby/unicorn.sock** for http servers
to serve from.

#Deploying the Robby application

##The robby class

The only class necessary to declare is **robby**.  Most parameter defaults will
be fine.  The only required parameters is the deploy_key and ldap setting
parameters.

###Parameter: deploy_app
**Required: no**
**Default value: true**

This parameter sets whether or not to declare the package resource that
installs the application. The only time you'd want to set this to **false** is
during development. It exists to serve the Robby application's development
environment where Vagrant shares the git clone to the destination directory,
making a package deploy unnecessary.

###Parameter: version 
**Required: no**
**Default value: latest**

This parameter accepts a package version.  If left
unset, it installs the latest version every run.

###Parameter: robby_path
**Required: no**
**Default value: /opt/robby**

Where to install the application on the node.

###Parameter: robby_home_directory
**Required: no**
**Default value: undef**

A robby user is created by this class to store the deployment SSH key.  This
parameter sets that user's home directory which defaults to /home/robby.

###Parameter: ldap_admin_cn
**Required: yes**

This parameter accepts the CN path to the admin user in ldap.  An example value
is **cn=ldapauth,ou=users,dc=example,dc=com**

###Parameter: ldap_host
**Required: yes**

The DNS name of the LDAP server

###Parameter: ldap_admin_password
**Required: yes**

The password of the admin user defined in **ldap_admin_cn**

###Parameter: ldap_people_ou
**Required: yes**

The base OU path in ldap where CN objects of people in the organization are in.
An example value is **ou=users,dc=example,dc=com**

## Choosing a http server

This module deploys the Robby application and manages the unicorn service
**unicorn_robby**.  However, the service only creates a socket to serve the
application and doesn't handle any HTTP requests.  Further, this module doesn't
manage git, which is required to deploy the application. 

As an example, to serve the application using nginx, you might create a puppet
profile that looks like this:

```
class profile::robby {

  include ruby
  include robby

  nginx::unicorn { 'robby':
    servername     => 'robby.example.com',
    path           => '/opt/robby',
    unicorn_socket => '/var/run/robby/unicorn.sock',
  }

  unicorn::app { 'robby':
    approot     => '/opt/robby',
    config_file => '/etc/unicorn_robby.rb',
    logdir      => '/var/log/robby',
    pidfile     => "/var/run/robby/unicorn.pid",
    socket      => "/var/run/robby/unicorn.sock",
    user        => 'robby',
    group       => 'robby',
    preload_app => true,
    rack_env    => 'production',
    source      => 'bundler',
    subscribe   => Class['robby'],
  }
}
```

The above example assumes you're managing the class parameters for the robby
class using data bindings.
