# This module should not be used directly. It is used by newrelic::php.
define newrelic::php::newrelic_ini (
  $newrelic_license_key,
  $exec_path,
) {
  notice "[DEBUG] detected PHP modules config directory: ${name}"

  case $::operatingsystem {
    'Debian': {
      $phpenmod_cmd = $::operatingsystemrelease ? {
        /^9/    => 'phpenmod',
        default => 'php5enmod'
      }
    }
    default: {
      $phpenmod_cmd = 'php5enmod'
    }
  }

  exec { "/usr/bin/newrelic-install ${name}" :
    path     => $exec_path,
    command  => "/usr/bin/newrelic-install purge ; NR_INSTALL_SILENT=yes NR_INSTALL_KEY=${newrelic_license_key} /usr/bin/newrelic-install install",
    provider => 'shell',
    user     => 'root',
    group    => 'root',
    unless   => "grep ${newrelic_license_key} ${name}/newrelic.ini",
    notify  => Exec["remove_old_ini_file"],
  }

  exec { "remove_old_ini_file" :
    path     => $exec_path,
    command  => "find ${name} -name newrelic.ini -delete",
    provider => 'shell',
    user     => 'root',
    group    => 'root',
    unless   => "grep ${newrelic_license_key} ${name}/newrelic.ini",
  }

  file { "${name}/newrelic.ini" :
    path    => "${name}/newrelic.ini",
    content => template('newrelic/newrelic.ini.erb'),
    require => Exec["/usr/bin/newrelic-install ${name}"],
    notify  => Exec["${phpenmod_cmd} newrelic"]
  }

  exec { "${phpenmod_cmd} newrelic" :
    path     => $exec_path,
    command  => "${phpenmod_cmd} newrelic",
    provider => 'shell',
    user     => 'root',
    group    => 'root',
    unless   => "grep ${newrelic_license_key} ${name}/newrelic.ini",
  }

}
