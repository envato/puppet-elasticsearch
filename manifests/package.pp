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
  $es_plugin_cmd = "${boxen::config::homebrewdir}/bin/elasticsearch-plugin"
  $javascript_plugin = 'lang-javascript'
  exec { "${es_plugin_cmd} install ${javascript_plugin}":
    unless  => "${es_plugin_cmd} list | grep javascript",
    require => Package[$package],
    notify  => Service['dev.elasticsearch'],
  }

}
