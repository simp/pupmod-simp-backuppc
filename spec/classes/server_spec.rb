require 'spec_helper'

describe 'backuppc::server' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) do
        facts
      end

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
