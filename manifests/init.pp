# == Class: backuppc
#
# Set up the BackupPC system with some sane defaults.
#
# This is set up to use rsync over SSH as it is the most secure option
# available. If you want something different, you will need to create your own
# version of this module.
#
# Sets up the authorized key on the client in such a way to only allow the
# BackupPC server.
#
# == Parameters
#
# [*backup_hosts*]
#   An array of hosts from which to allow access via this key.
#
# [*key_target*]
#   The location where the public key for the bpc_user she be placed.
#   This defaults to the location where the 'ssh' module would expect it.
#
# [*is_server*]
#   If true, enable the BackupPC server for this node.
#   You *must* set backuppc::server::cgi_admin_users if you set this.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class backuppc (
  $backup_hosts,
  $key_target = '/etc/ssh/local_keys/bpc_user',
  $is_server = false
) {

  if $is_server { include 'backuppc::server' }

  exec { 'bpc_user_noexpire':
    command => '/usr/bin/chage -E -1 -I -1 -M -1 bpc_user',
    unless  => '/usr/bin/test \( -z `/usr/bin/getent shadow bpc_user | /usr/bin/cut -f5,7,8 -d":" -- output-delimiter=""` \)',
    require => User['bpc_user']
  }

  group { 'bpc_user':
    ensure    => 'present',
    allowdupe => false,
    gid       => '610'
  }

  pam::access::manage { 'allow_bpc_user':
    users   => 'bpc_user',
    origins => ['ALL']
  }

  sudo::default_entry { 'bpc_user_no_requiretty':
    content  => ['!requiretty'],
    target   => 'bpc_user',
    def_type => 'user'
  }

  sudo::user_specification { 'bpc_user':
    user_list => 'bpc_user',
    host_list => 'ALL',
    runas     => 'root',
    cmnd      => '/usr/bin/rsync --server *',
    passwd    => false
  }

  user { 'bpc_user':
    ensure     => 'present',
    allowdupe  => false,
    comment    => 'Backup User',
    gid        => '610',
    uid        => '610',
    managehome => true,
    membership => 'inclusive',
    shell      => '/bin/bash',
    home       => '/var/local/bpc_user'
  }

  file { $key_target:
    ensure  => 'file',
    owner   => 'bpc_user',
    group   => 'root',
    mode    => '0640'
  }

  ssh_authorized_key { 'bpc_user':
    ensure  => 'present',
    key     => ssh_autokey('bpc_user','2048'),
    options => [ inline_template('from="<%= Array(@backup_hosts).join(\',\') %>"') ],
    target  => $key_target,
    type    => 'rsa',
    user    => 'bpc_user',
    require => File[$key_target]
  }

  validate_array($backup_hosts)
}
