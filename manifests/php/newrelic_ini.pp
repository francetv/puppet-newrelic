# This module should not be used directly. It is used by newrelic::php.
define newrelic::php::newrelic_ini (
  String $license_key = undef,
  String $exec_path   = undef,
  String $appname     = undef,
  Hash   $settings    = {},
) {

  $default_settings = {
    'newrelic/newrelic.enabled'                     => 'true',
    'newrelic/newrelic.distributed_tracing_enabled' => 'false',
    'newrelic/newrelic.license'                     => $license_key,
    'newrelic/newrelic.logfile'                     => "/var/log/newrelic/php_agent.log",
    'newrelic/newrelic.loglevel'                    => "info",
    'newrelic/newrelic.appname'                     => $appname
  }

  $real_settings = deep_merge(
    $default_settings,
    $settings
  )

  php::extension::config { 'newrelic':
    provider => 'apt',
    settings => $real_settings,
  }
}
