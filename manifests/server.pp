# == Class: backuppc::server
#
# Set up the BackupPC server.
#
# The system calling this will also need to be a BackupPC client to get the SSH
# keys properly generated and placed. This is also a good way to ensure that
# the system is working properly.
#
# Does the base configuration of the BackupPC configuration file.
#
# The main item that will generally be changed here is $authoritative_conf.
# Setting this to false (the default) will allow full configuration via the
# web GUI. Set to true will make this authoritative for the server.
#
# This will also set up the Apache configuration file to secure the server and
# do all appropriate redirection to the CGI scripts.
#
# This should only be defined once per scope.
#
# == Parameters
#
# Any variable that is not explicitly documented is explained in
# /etc/BackupPC/config.pl.example on the BackupPC server.
#
# The Apache documentation can explain additional details about any variable
# prefixed with 'httpd'
#
# [*data_dir*]
#   Type: Absolute Path
#   Default: versioncmp(simp_version(),'5') ? { '-1' => '/srv/BackupPC', default => '/var/BackupPC' }
#
# [*backup_hosts*]
#   An array of hosts from which to allow access via this key.
#
# [*cgi_admin_users*]
# [*umask_mode*]
# [*wakeup_schedule*]
# [*max_backups*]
# [*max_user_backups*]
# [*max_pending_commands*]
# [*max_backup_pc_nightly_jobs*]
# [*backup_pc_nightly_period*]
# [*max_old_log_files*]
# [*df_max_usage_percent*]
# [*trash_clean_sleep_sec*]
# [*full_period*]
# [*incr_period*]
# [*full_keep_cnt*]
# [*full_keep_cnt_min*]
# [*full_age_max*]
# [*incr_keep_cnt*]
# [*incr_levels*]
# [*partial_age_max*]
# [*restore_info_keep_cnt*]
# [*archive_info_keep_cnt*]
# [*blackout_bad_ping_limit*]
# [*blackout_good_cnt*]
# [*blackout_period_hour_end*]
# [*blackout_period_hour_begin*]
# [*blackout_period_weekdays*]
# [*backup_zero_files_is_fatal*]
# [*xfer_log_level*]
# [*client_charset*]
# [*client_charset_legacy*]
# [*archive_parity*]
# [*archive_split*]
# [*ping_path*]
# [*ping_max_msec*]
# [*compress_level*]
# [*client_timeout*]
# [*max_old_per_pc_log_files*]
# [*email_notify_min_days*]
# [*cgi_admin_user_group*]
# [*conf_language*]
# [*cgi_date_format_mmdd*]
# [*cgi_user_config_edit_enable*]
#
# [*authoritative_conf*]
#   Whether or not these variables are authoritative. If set to false, the
#   GUI will override any changes made here. However, these will be the
#   initial defaults.
#
# [*httpd_file_auth*]
#   Whether or not to use file based authentication.
#   If set to true, you will need to use backuppc::server::apache_user to
#   manage access to the sysetm.
#
# [*httpd_ldap_auth*]
#   Whether or not to use LDAP for authentication.
#
# [*httpd_ldap_group*]
#   An LDAP groupOfNames that the user must be in to access the system. This
#   does *not* translate to permissions inside of BackupPC.
#   Note: This can only be used if you are not using file based auth!
#
# [*httpd_posix_group*]
#   This sets AuthLDAPGroupAttributeIsDN to 'off' and AuthLDAPGroupAttribute
#   to 'memberUid' to support posixGroup entries in LDAP.
#
# [*httpd_ldap_servers*]
#   A space delimited list of LDAP servers to attempt to connect to. This is
#   *not* a URI string.  The default is to properly parse and use the
#   $ldapuri string specified in vars.pp.
#
# [*httpd_ldap_search*]
#   The space under which to search for entries.
#
# [*httpd_ldap_binddn*]
#   The Bind DN to use when binding to the LDAP server.
#
# [*httpd_ldap_bindpw*]
#   The Bind password to use when binding to the LDAP server.
#
# [*httpd_redirect_main*]
#   Whether or not to redirect the root space of your web server to BackupPC
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class backuppc::server (
  $data_dir = versioncmp(simp_version(),'5') ? { '-1' => '/srv/BackupPC', default => '/var/BackupPC' },
  $backup_hosts = $::backuppc::backup_hosts,
  $cgi_admin_users,
  $httpd_ldap_servers = hiera('ldap::uri'),
  $httpd_ldap_search = hiera('ldap::base_dn'),
  $httpd_ldap_binddn = hiera('ldap::bind_dn'),
  $httpd_ldap_bindpw = hiera('ldap::bind_pw'),
  $umask_mode = '23',
  $wakeup_schedule = [
    '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15',
    '16','17','18','19','20','21','22','23'
  ],
  $max_backups = '4',
  $max_user_backups = '4',
  $max_pending_commands = '10',
  $max_backup_pc_nightly_jobs = '2',
  $backup_pc_nightly_period = '1',
  $max_old_log_files = '14',
  $df_max_usage_percent = '95',
  $trash_clean_sleep_sec = '300',
  $full_period = '6.97',
  $incr_period = '0.97',
  $full_keep_cnt = ['1'],
  $full_keep_cnt_min = '1',
  $full_age_max = '90',
  $incr_keep_cnt = '6',
  $incr_keep_cnt_min = '1',
  $incr_age_max = '30',
  $incr_levels = ['1'],
  $partial_age_max = '3',
  $restore_info_keep_cnt = '10',
  $archive_info_keep_cnt = '10',
  $blackout_bad_ping_limit = '3',
  $blackout_good_cnt = '7',
  $blackout_period_hour_end = '19.5',
  $blackout_period_hour_begin = '7',
  $blackout_period_weekdays = ['1','2','3','4','5'],
  $backup_zero_files_is_fatal = '1',
  $xfer_log_level = '1',
  $client_charset = 'nil',
  $client_charset_legacy = 'iso-8859-1',
  $archive_parity = '0',
  $archive_split = '0',
  $ping_path = '/bin/ping',
  $ping_max_msec = '20',
  $compress_level = '3',
  $client_timeout = '72000',
  $max_old_per_pc_log_files = '12',
  $email_notify_min_days = '2.5',
  $cgi_admin_user_group = 'nil',
  $conf_language = 'en',
  $cgi_date_format_mmdd = '2',
  $cgi_user_config_edit_enable = '1',
  $authoritative_conf = false,
  $httpd_file_auth = true,
  $httpd_ldap_auth = false,
  $httpd_ldap_group = 'nil',
  $httpd_posix_group = true,
  $httpd_redirect_main = false
) {
  include '::backuppc'

  exec { 'backuppc_reload':
    command     => '/usr/bin/killall -HUP BackupPC',
    refreshonly => true
  }

  file { '/etc/BackupPC/apache.users':
    ensure  => 'file',
    owner   => 'backuppc',
    group   => 'apache',
    mode    => '0640',
    require => Package['BackupPC']
  }

  file { "${data_dir}/.ssh":
    ensure  => 'directory',
    owner   => 'backuppc',
    group   => 'backuppc',
    mode    => '0600',
    require => Package['BackupPC']
  }

  file { "${data_dir}/.ssh/id_rsa":
    ensure  => 'file',
    owner   => 'backuppc',
    group   => 'backuppc',
    mode    => '0600',
    content => ssh_autokey('bpc_user','2048',true),
    require => [
      Ssh_authorized_key['bpc_user'],
      Package['BackupPC']
    ]
  }

  group { 'backuppc':
    ensure    => 'present',
    allowdupe => false,
    require   => Package['BackupPC']
  }

  package { 'BackupPC': ensure => 'latest' }
  package { 'mod_perl': ensure => 'latest' }

  service { 'backuppc':
    ensure     => 'running',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => Package['BackupPC']
  }

  user { 'backuppc':
    ensure     => 'present',
    allowdupe  => false,
    comment    => 'BackupPC User',
    membership => 'inclusive',
    shell      => '/sbin/nologin',
    home       => $data_dir,
  }

  file { '/etc/BackupPC/config.pl':
    ensure  => 'file',
    owner   => 'backuppc',
    group   => 'apache',
    mode    => '0640',
    replace => $authoritative_conf,
    content => template('backuppc/config.pl.erb'),
    notify  => Exec['backuppc_reload'],
    require => Package['BackupPC']
  }

  apache::add_site { 'BackupPC':
    content => template('backuppc/httpd.erb')
  }

  # All appropriate SSL and conf variables must be set using hiera somewhere
  # such as /etc/puppet/hieradata/hosts/<fqdn>.yaml
  #
  # If no certs have been created for your browser, you may wish to set
  # sslverifyclient to 'none' for the Apache SSL setup. Also, it is recommended
  # that the user for the Apache conf be set to 'backuppc'.
  #
  # In the node config, <fqdn>.yaml, these options can be set like the following:
  #   apache::conf::user: "backuppc"
  #   apache::conf::group: "apache"
  #   apache::ssl::sslverifyclient: "none"
  include 'apache::ssl'
  include 'apache::conf'

  validate_absolute_path($data_dir)
  validate_array($backup_hosts)
  validate_integer($max_backups)
  validate_integer($max_user_backups)
  validate_integer($max_pending_commands)
  validate_integer($max_backup_pc_nightly_jobs)
  validate_integer($backup_pc_nightly_period)
  validate_integer($max_old_log_files)
  validate_integer($df_max_usage_percent)
  validate_integer($trash_clean_sleep_sec)
  validate_integer($full_keep_cnt_min)
  validate_integer($full_age_max)
  validate_integer($incr_keep_cnt)
  validate_integer($incr_keep_cnt_min)
  validate_integer($incr_age_max)
  validate_integer($partial_age_max)
  validate_integer($restore_info_keep_cnt)
  validate_integer($archive_info_keep_cnt)
  validate_integer($blackout_bad_ping_limit)
  validate_integer($blackout_good_cnt)
  validate_integer($backup_zero_files_is_fatal)
  validate_integer($xfer_log_level)
  validate_integer($archive_parity)
  validate_integer($archive_split)
  validate_integer($ping_max_msec)
  validate_integer($compress_level)
  validate_integer($client_timeout)
  validate_integer($max_old_per_pc_log_files)
  validate_integer($cgi_date_format_mmdd)
  validate_integer($cgi_user_config_edit_enable)
  validate_bool($authoritative_conf)
  validate_bool($httpd_file_auth)
  validate_bool($httpd_ldap_auth)
  validate_bool($httpd_posix_group)
  validate_bool($httpd_redirect_main)
}
