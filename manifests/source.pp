/*

== Class: tomcat::source

Installs tomcat 5.5.X or 6.0.X using the compressed archive from your favorite tomcat
mirror. Files from the archive will be installed in /opt/apache-tomcat/.

Class variables:
- *$log4j_conffile*: see tomcat

Requires:
- java to be previously installed
- archive definition (from puppet camptocamp/puppet-archive module)
- Package["curl"]

Tested on:
- RHEL 5,6
- Debian Lenny/Squeeze
- Ubuntu Lucid

Usage:
  include 'tomcat::source'

  or

  class { 'tomcat::source':
      version          => "6.0.26",
      mirror           => "http://archive.apache.org/dist/tomcat/",
      instance_basedir => "/srv/tomcat",
  }

*/
class tomcat::source (
    $version = "6.0.26",
    $mirror = "http://archive.apache.org/dist/tomcat/",
    $instance_basedir = "/srv/tomcat"
    ) inherits tomcat::base {

    $tomcat_home = "/opt/apache-tomcat-$version"
    # Determine major version by first char of version string.
    case $version {
       /^5.5/: {
            $maj_version = '5.5'
            $baseurl = "$mirror/tomcat-5/v$version/bin"
       } /^6/: {
            $maj_version = '6'
            $baseurl = "$mirror/tomcat-6/v$version/bin"

            # install extra tomcat juli adapters, used to configure logging.
            class {'tomcat::juli':
                tomcat_home => $tomcat_home,
            }

       } default: {
        fail('Unsuported version.')
       }
    }

    $tomcaturl = "${baseurl}/apache-tomcat-$version.tar.gz"

    include tomcat::logging

    case $::osfamily {
        RedHat: {
            package { ['log4j', 'jakarta-commons-logging']:
                ensure => present,
            }
        } Debian: {
            package { ['liblog4j1.2-java', 'libcommons-logging-java']:
                ensure => present,
            }
        } default: {
            fail("Unsupported OS family ${::osfamily}")
        }
    }

    archive{ "apache-tomcat-$version":
        checksum    => false,
        url         => $tomcaturl,
        digest_url  => "${tomcaturl}.md5",
        digest_type => 'md5',
        target      => '/opt',
    }

    file { '/opt/apache-tomcat':
        ensure  => link,
        target  => $tomcat_home,
        require => Archive["apache-tomcat-$version"],
        before  => [
            File['commons-logging.jar'],
            File['log4j.jar'],
            File['log4j.properties']
        ],
    }

    file { $tomcat_home:
        ensure  => directory,
        require => Archive["apache-tomcat-$version"],
    }

}
