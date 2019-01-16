# This module should not be used directly. It is used by newrelic::php.
define newrelic::php::newrelic_ini (
  String $newrelic_license_key = undef,
  String $exec_path            = undef,
  Hash   $settings             = {},
) {

  exec { "remove_old_ini_file" :
    path     => $exec_path,
    command  => "find ${name} -name newrelic.ini -delete",
    provider => 'shell',
    user     => 'root',
    group    => 'root',
    unless   => "grep ${newrelic_license_key} ${name}/newrelic.ini",
  }

  $default_settings =       {
    'newrelic/newrelic.enabled' => 'true',
    'newrelic/newrelic.license' => $newrelic_license_key,
    'newrelic/newrelic.logfile' => "/var/log/newrelic/php_agent.log",
    'newrelic/newrelic.loglevel' => "info",
    'newrelic/newrelic.appname' => "PHP Application",
  }

  if $settings != {} {
    $final_settings = deep_merge(
      $default_settings,
      $full_settings
    )
  } else {
    $final_settings = $default_settings
  }

  php::extension::config { 'newrelic':
    provider        => 'apt',
    settings        => $final_settings,
    require         => Exec["/usr/bin/newrelic-install ${name}"],
  }
}
