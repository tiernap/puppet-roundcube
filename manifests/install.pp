# Class: roundcube::install
#
# Install the Roundcube software package.
#
# === Authors
#
# Martin Meinhold <martin.meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2013 Martin Meinhold, unless otherwise noted.
#
class roundcube::install inherits roundcube {

  $archive = "roundcubemail-${roundcube::version}"
  $target = "${roundcube::install_dir}/${archive}"
  $download_url = "http://downloads.sourceforge.net/roundcubemail/${archive}-complete.tar.gz"

  archive { $archive:
    ensure           => present,
    digest_string    => $roundcube::checksum,
    digest_type      => $roundcube::checksum_type,
    url              => $download_url,
    follow_redirects => true,
    target           => $roundcube::install_dir,
    src_target       => $roundcube::package_dir,
    timeout          => 600,
    require          => [
      File[$roundcube::install_dir],
      File[$roundcube::package_dir]
    ],
  }

  file { ["${target}/logs", "${target}/temp"]:
    ensure  => directory,
    owner   => $roundcube::process,
    group   => $roundcube::process,
    mode    => '0644',
    require => Archive[$archive],
  }

  file { "${target}/installer":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
    backup  => false,
  }
}
