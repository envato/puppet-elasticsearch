class elasticsearch::package(
  $ensure  = $elasticsearch::params::ensure,
  $version = $elasticsearch::params::version,
  $package = $elasticsearch::params::package,
) inherits elasticsearch::params {

  $package_ensure = $ensure ? {
    present => $version,
    default => installed,
  }

  homebrew::formula { 'elasticsearch': }

  ->
  package { $package:
    ensure  => $package_ensure,
  }

}
