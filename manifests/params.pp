# Class: bacula::params
#
# This class contains the Bacula module parameters
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class bacula::params {

  # Port information
  $director_port = '9101'
  $file_port     = '9102'
  $storage_port  = '9103'

  $file_retention = '45 days'
  $job_retention  = '6 months'
  $autoprune      = 'yes'
  $monitor        = true
  $pe_ssl_dir     = '/etc/puppetlabs/puppet/ssl'

  $ssl            = true
  if $is_pe {
    $bacula_director  = hiera('pe_bacula_director')
    $bacula_storage   = hiera('pe_bacula_storage')
    $ssl_dir          = hiera('pe_ssl_dir', $pe_ssl_dir)
    $director_name    = hiera('pe_director_name', $bacula_director)
    $director_address = hiera('pe_director_address', $director_name)
  }
  else {
    $bacula_director  = hiera('bacula_director')
    $bacula_storage   = hiera('bacula_storage')
    $ssl_dir          = $puppet::params::puppet_ssldir
    $director_name    = hiera('director_name', $bacula_director)
    $director_address = hiera('director_address', $director_name)
}

  $bacula_is_storage  = hiera('bacula_is_storage')
  $listen_address     = hiera('bacula_client_listen')
 
   # Pool parameters for full backups
  $volret_full        = hiera('bacula::params::volret_full', '21 days')
  $maxvolbytes_full   = hiera('bacula::params::maxvolbytes_full', '4g')
  $maxvoljobs_full    = hiera('bacula::params::maxvoljobs_full', '10')
  $maxvols_full       = hiera('bacula::params::maxvols_full', '100')

  # Pool parameters for incremental backups
  $volret_incremental      = hiera('bacula::params::volret_incremental', '8 days')
  $maxvolbytes_incremental = hiera('bacula::params::maxvolbytes_incremental', '4g')
  $maxvoljobs_incremental  = hiera('bacula::params::maxvoljobs_incremental', '50')
  $maxvols_incremental     = hiera('bacula::params::maxvols_incremental', '100')

  $job_pool           = hiera('bacula::params::job_pool', 'Default')
  $job_defs           = hiera('bacula::params::job_defs', 'PuppetLabsOps')

  # If there is a bacula_password fact, use that. Else generate a new password.
  # HAY GUISE, GUESS WHAT VARIABLE GOT STRINGIFIED FROM NIL TO AN EMPTY STRING?
  # haet.
  $bacula_password = $::bacula_password ? {
    ''      => genpass({}),
    default => $::bacula_password,
  }

  case $::operatingsystem {
    'ubuntu','debian': {
        $bacula_director_packages = [ 'bacula-director-common', 'bacula-director-mysql', 'bacula-console' ]
        $bacula_director_services = [ 'bacula-director' ]
        $bacula_storage_packages  = [ 'bacula-sd', 'bacula-sd-mysql' ]
        $bacula_storage_services  = [ 'bacula-sd' ]
        $bacula_client_packages   = 'bacula-client'
        $bacula_client_services   = 'bacula-fd'
        $bacula_parent_dir        = '/etc/bacula'
        $bacula_dir               = '/etc/bacula/ssl'
        $client_config            = '/etc/bacula/bacula-fd.conf'
        $working_directory        = '/var/lib/bacula'
        $pid_directory            = '/var/run/bacula'
    }
    'centos','fedora','sles': {
        $bacula_director_packages = [ 'bacula-director-common', 'bacula-director-mysql', 'bacula-console' ]
        $bacula_director_services = [ 'bacula-dir' ]
        $bacula_storage_packages  = [ 'bacula-sd', 'bacula-sd-mysql' ]
        $bacula_storage_services  = [ 'bacula-sd' ]
        $bacula_client_packages   = 'bacula-client'
        $bacula_client_services   = 'bacula-fd'
        $bacula_parent_dir        = '/etc/bacula'
        $bacula_dir               = '/etc/bacula/ssl'
        $client_config            = '/etc/bacula/bacula-fd.conf'
        $working_directory        = '/var/lib/bacula'
        $pid_directory            = '/var/run'
    }
    'freebsd': {
        $bacula_client_packages = 'sysutils/bacula-client'
        $bacula_client_services = 'bacula-fd'
        $bacula_parent_dir      = '/usr/local/etc/bacula'
        $bacula_dir             = '/usr/local/etc/bacula/ssl'
        $client_config          = '/usr/local/etc/bacula/bacula-fd.conf'
        $pid_directory          = '/var/run'
        $working_directory      = '/var/db/bacula'
    }
    default: { fail("bacula::params has no love for ${::operatingsystem}") }
  }

}
