# == Define: netinstall
#
# Install tarball/binary style install packages.
#
# === Parameters
#
#
# [*title*]
#   url of tarball binary install
#
# [*extract_dir*]
#   directory created after extraction. default based on title by removing
#   extension
#
# [*dest_dir*]
#   destination where to extract tarball
#
# [*owner*]
#   owner of the extracted files/directories
#
# [*group*]
#   group of the extracted files/directories
#
# === Examples
#
#  netinstall{"http://download.repos.org/file.tgz":}
#
# === Authors
#
# Greg Shively <shivelyg@gmail.com>
#
# === Copyright
#
# Copyright 2014 Greg Shively
#

define netinstall(

	$extract_dir     = undef,
	$dest_dir        = "/opt",
	$owner           = "root",
	$group           = "root",

) {

	Exec{ cwd => $dest_dir, path => "/usr/bin:/bin" }

	$url  = regsubst($title, '^(.+)/[^/]+$', '\1')
	$file = regsubst($title, '^.+/([^/]+)$', '\1')

	case $file {
		/.*\.tar\.Z/:  { 
			$extract_cmd = "tar -xZf $file" 
			$base = regsubst($file, '([^:/]+)\.tar\.Z$', '\1')
		}
		/.*\.tar\.gz/: { 
			$extract_cmd = "tar -xzf $file" 
			$base = regsubst($file, '([^:/]+)\.tar\.gz$', '\1')
		}
		/.*\.tgz/:     { 
			$extract_cmd = "tar -xzf $file" 
			$base = regsubst($file, '([^:/]+)\.tgz$', '\1')
		}
		default:       { 
			$extract_cmd = "chmod +x $file && ./$file" 
		}
	}

	if $extract_dir {
		$real_extract = $extract_dir
	}
	elsif $base {
		$real_extract = $base
	}
	else {
		fail("Must specify extract_dir")
	}

	exec { "$dest_dir/$real_extract":
		command     => "curl -Osf $title && $extract_cmd ; rm $file",
		creates     => "$dest_dir/$real_extract",
	}

	exec { "chown -R $owner:$group $dest_dir/$real_extract":
		command     => "chown -R $owner:$group $dest_dir/$real_extract",
		refreshonly => true,
		subscribe   => Exec["$dest_dir/$real_extract"],
	}

}
