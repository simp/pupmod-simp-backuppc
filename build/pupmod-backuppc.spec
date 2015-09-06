Summary: BackupPC Puppet Module
Name: pupmod-backuppc
Version: 4.1.0
Release: 5
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-apache >= 4.1.0-4
Requires: pupmod-ssh >= 4.1.0-7
Requires: puppet >= 3.3.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-backuppc-test

Prefix: /etc/puppet/environments/simp/modules

%description
A module to create and configure a BackupPC backup environment. This includes
both server and client capabilities.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/backuppc

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/backuppc
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/backuppc
cp README.md %{buildroot}/%{prefix}/backuppc

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/backuppc

%files
%defattr(0640,root,puppet,0750)
%{prefix}/backuppc

%post
#!/bin/sh

if [ -d %{prefix}/backuppc/plugins ]; then
  /bin/mv %{prefix}/backuppc/plugins %{prefix}/backuppc/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Thu Feb 19 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-5
- Migrated to the new 'simp' environment.

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-4
- Updated the dependency on pupmod-ssh for the new ssh_autokeys function.
- Changed puppet-server requirement to puppet

* Mon Jul 21 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-3
- Updated to use /var/BackupPC for SIMP>=5

* Tue Apr 15 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-2
- Updated pam::groupaccess::modify references to pam::access::manage to
  reflect recent changes to PAM module.
- Updated manifests to clean up code a bit (spacing and styling).
- Fixed spec tests and hiera variables.
- Changed all ldap top-level variables to reflect new conventions of ldap::<var>.

* Fri Feb 21 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-1
- Updated the bpc_user_noexpire exec to use an 'unless' instead of
  'refreshonly'. This ensures that, should the user be created by a
  means other than Puppet, it will not expire.

* Mon Dec 09 2013 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-0
- Updated to be more compatible with Puppet 3.X and hiera.

* Thu Oct 03 2013 Nick Markowski <nmarkowski@keywcorp.com> - 2.0.0-9
- Updated template to reference instance variables with @

* Thu Jun 27 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0.0-8
- Removed the ping facl exec since the security module no longer locks
  down the permissions on ping.

* Thu Jan 31 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0.0-7
- Created a Cucumber test that sets up and checks backuppc.

* Fri Jul 20 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0.0-6
- No longer manage the backuppc user UID.
- Ensure that the bpc_user key file is created before trying to write the key
  itself due to the way Puppet now handles ssh authorized keys.
- Modified the backuppc RewriteRule to only redirect if it starts with
  /BackupPC. This should fix the case where the yum server holding
  BackupPC is on the same system as BackupPC itself.

* Wed Apr 11 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0.0-5
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0.0-4
- Actually included the README in the RPM!
- Improved test stubs.

* Mon Jan 30 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0-3
- Added test stubs.

* Mon Dec 26 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0-2
- Updated the spec file to not require a separate file list.

* Fri Aug 05 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 2.0-1
- Added a usage README to the module directory.

* Tue Mar 08 2011 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0-0
- Initial Build.
