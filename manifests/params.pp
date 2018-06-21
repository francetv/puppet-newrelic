# Class: newrelic::params
#
# This class configures parameters for the puppet-newrelic module.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class newrelic::params {

  case $::osfamily {
    'RedHat': {
      $newrelic_package_name  = 'newrelic-sysmond'
      $newrelic_service_name  = 'newrelic-sysmond'
      $newrelic_php_package   = 'newrelic-php5'
      $newrelic_php_service   = 'newrelic-daemon'
      $newrelic_php_conf_dir  = ['/etc/php.d']
      $newrelic_service_provider = 'init'
      package { 'newrelic-repo-5-3.noarch':
        ensure   => present,
        source   => 'http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm',
        provider => rpm,
      }
    }
    'Debian': {
      $newrelic_package_name  = 'newrelic-sysmond'
      $newrelic_service_name  = 'newrelic-sysmond'
      $newrelic_php_package   = 'newrelic-php5'
      $newrelic_php_service   = 'newrelic-daemon'
      case $::operatingsystem {
        'Debian': {
          case $::operatingsystemrelease {
            /^9/: {
              if $::phpversion and $::phpversion =~ /^(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)/ {
                $majeur_version = $1
                if $2 == undef {
                  $minor_version = $3
                } else {
                  $minor_version = $2
                }
                $php_real_version = "${majeur_version}.${minor_version}"
              }
              $newrelic_php_conf_dir     = ["/etc/php/${php_real_version}/mods-available"]
              $newrelic_service_provider = 'systemd'
            }
            /^8/: {
              case $::phpversion {
                /^7/: {
                  $newrelic_php_conf_dir  = ['/etc/php/7.0/mods-available']
                }
                default:{
                  $newrelic_php_conf_dir  = ['/etc/php5/mods-available']
                }
              }
              $newrelic_service_provider = 'init'
            }
            /^6/: {
              $newrelic_php_conf_dir  = ['/etc/php5/conf.d']
              $newrelic_service_provider = 'init'
            }
            default: {
              $newrelic_php_conf_dir  = ['/etc/php5/mods-available']
              $newrelic_service_provider = 'init'
            }
          }
        }
        'Ubuntu': {
          case $::operatingsystemrelease {
            /^(10|12)/: {
              $newrelic_php_conf_dir  = ['/etc/php5/conf.d']
            }
            default: {
              $newrelic_php_conf_dir  = ['/etc/php5/mods-available']
            }
          }
        }
        default: {
          $newrelic_php_conf_dir  = ['/etc/php5/conf.d']
        }
      }
    }
    'windows': {
      $bitness                        = regsubst($::architecture,'^x([\d]{2})','\1')
      $newrelic_package_name          = 'New Relic Server Monitor'
      $newrelic_service_name          = 'nrsvrmon'
      $temp_dir                       = 'C:/Windows/temp'
      $server_monitor_source          = 'http://download.newrelic.com/windows_server_monitor/release/'
      $newrelic_dotnet_conf_dir       = 'C:\\ProgramData\\New Relic\\.NET Agent'
      $newrelic_dotnet_package        = "New Relic .NET Agent (${bitness}-bit)"
      $newrelic_dotnet_source         = 'http://download.newrelic.com/dot_net_agent/release/'
      $newrelic_service_provider      = 'windows'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}")
    }
  }

}
