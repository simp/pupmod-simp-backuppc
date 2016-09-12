[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-backuppc.svg)](https://travis-ci.org/simp/pupmod-simp-backuppc) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with backuppc](#setup)
    * [What backuppc affects](#what-backuppc-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with backuppc](#beginning-with-backuppc)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)
6. [Acceptance Tests](#acceptance-tests)

## This is a SIMP module
This module is a component of the [System Integrity Management Platform](https://github.com/NationalSecurityAgency/SIMP), a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our [JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP) and visit our [developer wiki](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home).


## Module Description

BackupPC is a utility for archiving and restoring data from a central,
networked, location. The backuppc module allows for general use and
setup, but the default configuration is designed to securely pass data
using rsync over SSH.

## Setup

### What backuppc affects

BackupPC installs the BackupPC Package, manages the service and will set a
non-authoritave configuration, that can be changed within the BackuPC GUI.

### Setup Requirements

A node should be selected as the BackupPC server before clients are configured
with BackupPC

### Beginning with backuppc

To get the basic BackupPC setup working in your environment, you
should follow either the File Based Authentication or LDAP
Authentication below.

Look at the code comments or the developer section under 'simp doc'
for additional information on extended usage.

## Usage

### Server Configuration with File Based Authentication

This method allows for a basic setup and will provide you with a
working environment using Apache's file based basic authentication.

```puppet
  # Repeat this for every user you want on the system.
  backuppc::server::user { 'username':
    password => 'output of ruby -r sha1 -r base64 -e 'puts "{SHA}"+Base64.encode64(Digest::SHA1.digest("password"))''
  }

include 'backuppc'
```

An example of <fqdn>.yaml:

```yaml
---
backuppc::is_server: true
backuppc::backup_hosts:
  - backupserver.example.domain
backuppc::server::cgi_admin_users:
  - user1
  - user2
apache::conf::user: 'backuppc'
apache::conf::group: 'apache'
# Only set this if your clients have personal certificates.
apache::ssl::sslverifyclient: 'none'
```

### Server Configuration with LDAP Authentication

```puppet
include 'backuppc'
```

An example <fqdn>.yaml config:

```
---
backuppc::backup_hosts:
  - 'backupserver.example.domain'
backuppc::server::cgi_admin_users:
  - 'user1'
  - 'user2'
backuppc::server::httpd_file_auth: false
backuppc::server::httpd_ldap_auth: true
apache::conf::user: 'backuppc'
apache::conf::group: 'apache'
apache::ssl::sslverifyclient: 'none'
```

At this point, you should be able to access BackupPC by accessing
https://<your_servername>/BackupPC.

### Configuring the Client

The client is much simpler to set up.

```puppet
  include 'backuppc'
```

With the following in Hiera:

```yaml
---
backuppc::backup_hosts:
  - 'backupserver.example.domain'
```

--------------

> NOTES
>
> * After the first run, puppet is no longer authoritative for the BackupPC
>   configuration by default. If you want puppet to be authoritative, you'll
>   need to set $authoritative_conf to 'true' when calling
>   backuppc::server::conf
>
> * This module automatically creates an SSH user key for BackupPC that is used
>   by the bpc_user. This will not be created until a call to backuppc::conf has
>   been made.
>
> * You can use both httpd_file_auth and httpd_ldap_auth simultaneously if you
>   so choose.
>
> The BackupPC web page: http://backuppc.sourceforge.net/

-------------

## Limitations

SIMP Puppet modules are generally intended to be used on a Red Hat Enterprise Linux-compatible distribution.

## Development

Please read our [Contribution Guide](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP) and visit our [Developer Wiki](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home)

If you find any issues, they can be submitted to our [JIRA](https://simp-project.atlassian.net).

[SIMP Contribution Guidelines](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP)

[System Integrity Management Platform](https://github.com/NationalSecurityAgency/SIMP)

## Acceptance tests

To run the system tests, you need `Vagrant` installed.

You can then run the following to execute the acceptance tests:

```shell
   bundle exec rake beaker:suites
```

Some environment variables may be useful:

```shell
   BEAKER_debug=true
   BEAKER_provision=no
   BEAKER_destroy=no
   BEAKER_use_fixtures_dir_for_modules=yes
```

*  ``BEAKER_debug``: show the commands being run on the STU and their output.
*  ``BEAKER_destroy=no``: prevent the machine destruction after the tests
   finish so you can inspect the state.
*  ``BEAKER_provision=no``: prevent the machine from being recreated.  This can
   save a lot of time while you're writing the tests.
*  ``BEAKER_use_fixtures_dir_for_modules=yes``: cause all module dependencies
   to be loaded from the ``spec/fixtures/modules`` directory, based on the
   contents of ``.fixtures.yml``. The contents of this directory are usually
   populated by ``bundle exec rake spec_prep``. This can be used to run
   acceptance tests to run on isolated networks.
~
