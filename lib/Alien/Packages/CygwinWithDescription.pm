package Alien::Packages::CygwinWithDescription;

use strict;
use warnings;
use Cygwin::PackageDB;
use Cygwin::PackageDB::Mirror;
use base qw( Alien::Packages::Cygwin );

# ABSTRACT: Get information from Cygwin's packages via cygcheck and Cygwin::PackageDB
# VERSION

=head1 SYNOPSIS

 # without Alien::Packages
 ues Alien::Packages::CygwinWithDescription;
 
 foreach my $package (Alien::Packages::CygwinWithDescription->list_packages)
 {
   say 'Name:    ' . $package->{Name};
   say 'Version: ' . $package->{Version};
 }
 
 my $perl_package = Alien::Packages::CygwinWithDescription->list_owners('/usr/bin/perl');
 say 'Perl package is ' . $perl_package->{"/usr/bin/perl"}->[0]->{Package};
 
 # with Alien::Packages
 use Alien::Packages;
 
 my $packages = Alien::Packages->new;
 foreach my $package ($packages->list_packages)
 {
   say 'Name:    ' . $package->{Name};
   say 'Version: ' . $package->{Version};
 }
 
 my $perl_package = $packages->list_owners('/usr/bin/perl');
 say 'Perl package is ' . $perl_package->{"/usr/bin/perl"}->[0]->{Package};

=head1 DESCRIPTION

This module provides package information for the Cygwin environment.
It can also be used as a plugin for L<Alien::Packages>, and will be
used automatically if the environment is detected.  This module is a 
subclass of L<Alien::Packages::Cygwin> which works identically, except
that it uses the Cygwin package database (via L<Cygwin::PackageDB> and
L<LWP::UserAgent>) to include the package descriptions.  The package
database is cached.

=cut

sub pkgtype { 'cygwin' }

=head1 METHODS

=head2 usable

 my $usable = Alien::Packages::cygwin->usable;

Returns true when cygcheck command was found in the path.

=cut

sub usable
{
  my $self = shift;
  $self->SUPER::usable(@_);
}

=head2 list_packages

 my @packages = Alien::Packages::Cygwin->list_packages;

Returns the list of installed I<cygwin> packages.  Each package is returned
as a hashref containing a

=over 4

=item Package

The name of the package

=item Version

The version of the package

=item Description

The description of the package

=back

=cut

sub list_packages
{
  my $self = shift;
  $self->SUPER::list_packages(@_);
}

=head2 list_fileowners

This method works exactly like L<Alien::Packages::Cygwin#list_fileowners>.

=cut

# TODO: cache
# File::HomeDir->my_dist_data('Alien-Packages-CygwinWithDescription', { create => 1 });
sub _pl
{
  my $self = shift;
  
  if(ref $self)
  {
    return $self->{_pl} if defined $self->{_pl};
  }

  my $db = Cygwin::PackageDB->new(scheme => 'http');
  
  if(defined $ENV{CYGWIN_PACKAGEDB_MIRROR})
  {
    $db->mirror(
      Cygwin::PackageDB::Mirror->new($ENV{CYGWIN_PACKAGEDB_MIRROR})
    );
  }
  
  my $pl = $db->package_list( arch => $self->_arch );
  
  if(ref $self)
  {
    $self->{_pl} = $pl;
  }  
  
  $pl;
}

my $arch;

sub _arch
{
  unless(defined $arch)
  {
    # 32 bit uname -m returns i686 but we want x86
    my $m = ((POSIX::uname)[4]);
    $arch = $m eq 'x86_64' ? 'x86_64' : 'x86';
  }

  $arch;
}

1;
