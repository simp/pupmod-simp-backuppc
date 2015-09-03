#require 'spec_helper'
#
#describe 'backuppc::server' do
#
#  base_facts = {
#    :ldapuri            => 'ldap://foo.example.domain',
#    :lsbdistrelease    => '6.5',
#    :lsbmajdistrelease  => '6',
#    :operatingsystem    => 'RedHat',
#    :interfaces => 'eth0',
#    :hardwaremodel => 'x86_64',
#    :grub_version => '2.0',
#    :uid_min => '500'
#  }
#
#  let(:facts) {base_facts}

require 'spec_helper'

describe 'backuppc::server' do

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) do
        facts
      end

      context "on #{os}" do


        context 'base' do
          let(:params) {{
            :cgi_admin_users    => ['user1', 'user2'],
            :data_dir => '/var/BackupPC'
          }}
      
          it { is_expected.to create_class('backuppc::server') }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_service('backuppc').that_requires('Package[BackupPC]') }
          it { is_expected.to contain_file('/etc/BackupPC/apache.users').that_requires('Package[BackupPC]') }
          it { is_expected.to contain_file('/etc/BackupPC/config.pl').that_requires('Package[BackupPC]')  }
          it { is_expected.to contain_file('/var/BackupPC/.ssh').that_requires('Package[BackupPC]') }
          it { is_expected.to contain_file('/var/BackupPC/.ssh/id_rsa') }
          it { is_expected.to contain_class('apache::ssl') }
          it { is_expected.to contain_class('apache::conf') }
        end
      
        context 'alternate_data_dir' do
          let(:params){{
            :data_dir => '/srv/BackupPC',
            :cgi_admin_users    => ['user1', 'user2']
          }}
          it { is_expected.to contain_file('/srv/BackupPC/.ssh/id_rsa') }#.that_requires('Package[BackupPC]') }
        end
      end
    end
  end
end
