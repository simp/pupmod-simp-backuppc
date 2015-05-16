# == Define: backuppc::server::user
#
# This lets you add local users to BackupPC via the htaccess authorization
# file.
#
# This file is hard coded by the module at /etc/BackupPC/apache.users.
#
# == Parameters
#
# [*name*]
#   The user that you would like to add to the system.
#
# [*password*]
#   The password of the user. This can either be plain text or can be an SHA
#   hash prefixed with {SHA}. You can generate your own SHA hashes with the
#   following snippet of Ruby code.
#
#   If you put in a plain text password, the result will be hashed on the
#   target system.
#
#   require 'sha1'
#   require 'base64'
#   puts '{SHA}'+Base64.encode64(Digest::SHA1.digest('password'))
#
# [*ensure*]
#   What to do with the user. Adds by default.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define backuppc::server::user (
  $password,
  $ensure = 'present'
) {

  $l_target = '/etc/BackupPC/apache.users'

  htaccess { "${l_target}:${name}":
    ensure   => $ensure,
    password => $password
  }
}
