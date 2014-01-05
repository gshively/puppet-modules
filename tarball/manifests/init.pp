# == Type: tarball
#
# "Package" tool to install tarball/zip/self-extract binary style
#     installers located on a possible remote location retrieved
#     by curl
#
# === Parameters
#
# Document parameters here.
#
# [*title*]
#    The file needed to be retrieved and extracted
#
# [*source*]
#    Where the file lives - retrieved by curl. Support any curl URLs
#
# [*target*]
#    target directory to located the extracted directory
#
# [*extract_dir*]
#    Directory name created. Default attempts to retrieve from the
#    filename by the name-version.tar.gz style of naming
#
# [*owner*]
#    owner of the extracted files/directories
#
# [*group*]
#    group of the extracted files/directories
#
# [*ensure*]
#    present or absent
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
# tarball{"package-1.0.tar.gz":}
#
# === Authors
#
# Greg Shively <shivelyg@gmail.com>
#
# === Copyright
#
# Copyright 2014 Greg Shively
#
define tarball(

	$source,
	$target              = '/opt',
    $extract_dir         = undef,
	$owner               = 'root',
	$group               = 'root',
	$ensure              = 'present',
	$install_env         = [],
	$bin_options         = '',

) {
	Exec{ cwd => $target, path => '/usr/bin:/bin', environment => $install_env }
	$url = "$source/$title"

	if ! ($ensure in [ 'present', 'absent' ]) {
		fail("ensure must be either 'present' or 'absent', not '$ensure'")
	}

	case $title {
		/(.*)\.tgz$/:     { $cmd  = "tar -xzf $title" $base = $1 }
		/(.*)\.tar\.gz$/: { $cmd  = "tar -xzf $title" $base = $1 }
		/(.*)\.tar\.Z$/:  { $cmd  = "tar -xZf $title" $base = $1 }

		default:          {
			$cmd  = "chmod +x $title && ./$title $bin_options"
			$base = undef
		}
	}

	if   $extract_dir { $dir = $extract_dir } else { $dir = $base }
	if ! $dir       { fail("Must specify 'extract_dir' for '$title'") }

	if $ensure == 'present' {

		exec {"$cmd":
			command     => "curl -Osf $url || exit 1 && $cmd ; rm $title",
			creates     => "$target/$dir",
		}

		exec {"chown -R $owner:$group $target/$dir":
			command     => "chown -R $owner:$group $target/$dir",
			refreshonly => true,
			subscribe   => Exec["$cmd"],
		}

		file {"$target/$dir":
			owner       => $owner,
			group       => $group,
			ensure      => directory,
			noop        => true,
			require     => Exec["chown -R $owner:$group $target/$dir"],
		}

	}
	else {

		exec{"rm -rf $target/$dir":
			command     => "rm -rf $dir",
			unless      => "test -d $dir",
		}

	}
	
}
