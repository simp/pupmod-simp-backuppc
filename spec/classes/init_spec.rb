require 'spec_helper'

describe 'backuppc' do
  #let(:title) {'backuppc'}

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) do
        facts
      end

      context "on #{os}" do

        it { is_expected.to create_class('backuppc') }
        it { is_expected.to compile.with_all_deps }
      
        it do
          is_expected.to contain_file('/etc/ssh/local_keys/bpc_user').with({
            'ensure' => 'file',
            'owner'  => 'bpc_user',
            'group'  => 'root',
            'mode'   => '0640'
          })
        end
      
        it do
          is_expected.to contain_user('bpc_user').with(
            'ensure'     => 'present',
            'allowdupe'  => 'false',
            'comment'    => 'Backup User',
            'gid'        => '610',
            'uid'        => '610',
            'managehome' => 'true',
            'membership' => 'inclusive',
            'shell'      => '/bin/bash',
            'home'       => '/var/local/bpc_user'
          )
        end
      
        it do
          is_expected.to contain_group('bpc_user').with(
            'ensure'    => 'present',
            'allowdupe' => 'false',
            'gid'       => '610'
          )
        end
      
        context 'check_ssh_authorized_key_single_host' do
          let(:params) { {:backup_hosts => ['test.foo.domain']} }
          it do
            is_expected.to contain_ssh_authorized_key('bpc_user').with({
              'options' => ['from="test.foo.domain"']
            })
          end
        end
      end
    end
  end
end
