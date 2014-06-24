# Internal: Manages the elasticsearch package
#
class elasticsearch::package(
  $ensure  = $elasticsearch::params::ensure,
  $version = $elasticsearch::params::version,
  $package = $elasticsearch::params::package,
) inherits elasticsearch::params {

  $package_ensure = $ensure ? {
    present => $version,
    default => installed,
  }

  if $::operatingsystem == 'Darwin' {
    homebrew::formula { 'elasticsearch': }
  }

  package { $package:
    ensure  => $package_ensure,
  }

  # TODO turn this into a proper puppet definition if we have more plugins
  $es_plugin_cmd = "${boxen::config::homebrewdir}/bin/plugin"
  $javascript_plugin = 'elasticsearch/elasticsearch-lang-javascript/2.1.0'
  exec { "${es_plugin_cmd} --install ${javascript_plugin}":
    unless => "${es_plugin_cmd} --list | grep javascript",
    notify => Service['dev.elasticsearch'],
  }

  $es_head_plugin = 'mobz/elasticsearch-head'
  exec { "${es_plugin_cmd} --install ${es_head_plugin}":
    unless => "${es_plugin_cmd} --list | grep head",
    notify => Service['dev.elasticsearch'],
  }

}
