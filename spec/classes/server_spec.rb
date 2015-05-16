require 'spec_helper'

describe 'backuppc::server' do

  base_facts = {
    :ldapuri            => 'ldap://foo.example.domain',
    :lsbdistrelease    => '6.5',
    :lsbmajdistrelease  => '6',
    :operatingsystem    => 'RedHat',
    :interfaces => 'eth0',
    :hardwaremodel => 'x86_64',
    :grub_version => '2.0',
    :uid_min => '500'
  }

  let(:facts) {base_facts}

  context 'base' do
    let(:params) {{
      :cgi_admin_users    => ['user1', 'user2'],
      :data_dir => '/var/BackupPC'
    }}

    it { should create_class('backuppc::server') }
    it { should compile.with_all_deps }
    it { should contain_package('BackupPC').that_comes_before('Service[backuppc]') }
    it { should contain_package('BackupPC').that_comes_before('File[/etc/BackupPC/apache.users]') }
    it { should contain_package('BackupPC').that_comes_before('File[/etc/BackupPC/config.pl]') }
    it { should contain_package('BackupPC').that_comes_before('File[/var/BackupPC/.ssh/id_rsa]') }
    it { should contain_class('apache::ssl') }
    it { should contain_class('apache::conf') }
    it { should contain_ssh_authorized_key('bpc_user').that_comes_before('File[/var/BackupPC/.ssh/id_rsa]') }
  end

  context 'alternate_data_dir' do
    let(:params){{
      :data_dir => '/srv/BackupPC',
      :cgi_admin_users    => ['user1', 'user2']
    }}
    it { should contain_package('BackupPC').that_comes_before('File[/srv/BackupPC/.ssh/id_rsa]') }
  end

end
