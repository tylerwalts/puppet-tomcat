/*

== Class: tomcat::juli

Installs 2 extra components to $tomcat_home, required to configuring logging on
tomcat6. See: http://tomcat.apache.org/tomcat-6.0-doc/logging.html

Attributes:
- *tomcat_home*: path to tomcat installation directory.

This class is just there to avoid code duplication. It probably doesn't make
any sense to include it directly.

*/
class tomcat::juli {

  if ( $tomcat_home ) {
  } elsif (  $::tomcat::source::tomcat_home ) {
    $tomcat_home = $::tomcat::source::tomcat_home
  } else {
    err('undefined mandatory attribute: $tomcat_home')
  }

  $baseurl = "${tomcat::source::mirror}/tomcat-6/v${tomcat::source::version}/bin"

  file { "${tomcat_home}/extras/":
    ensure  => directory,
    require => File[$tomcat_home],
  }

  archive::download { "tomcat-juli.jar":
    checksum    => false,
    url         => "${baseurl}/extras/tomcat-juli.jar",
    digest_url  => "${baseurl}/extras/tomcat-juli.jar.md5",
    digest_type => "md5",
    src_target  => "${tomcat_home}/extras/",
    require     => File["${tomcat_home}/extras/"],
  }

  archive::download { "tomcat-juli-adapters.jar":
    checksum    => false,
    url         => "${baseurl}/extras/tomcat-juli-adapters.jar",
    digest_url  => "${baseurl}/extras/tomcat-juli-adapters.jar.md5",
    digest_type => "md5",
    src_target  => "${tomcat_home}/extras/",
    require     => File["${tomcat_home}/extras/"],
  }

  file { "${tomcat_home}/bin/tomcat-juli.jar":
    ensure  => link,
    target  => "${tomcat_home}/extras/tomcat-juli.jar",
    require => Archive::Download["tomcat-juli.jar"],
  }

  file { "${tomcat_home}/lib/tomcat-juli-adapters.jar":
    ensure  => link,
    target  => "${tomcat_home}/extras/tomcat-juli-adapters.jar",
    require => Archive::Download["tomcat-juli-adapters.jar"],
  }

}
