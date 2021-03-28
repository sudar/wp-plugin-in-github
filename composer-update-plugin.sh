#!/bin/bash

################################################################################
# Update WordPress plugins that are included using composer.

# Author: Sudar <http://sudarmuthu.com>
#
# License: Beerware ;)
#
# You should invoke this script from the Plugin directory, but you don't need
# to copy this script to every Plugin directory. You can just have one copy
# somewhere and then invoke it from multiple Plugin directories.
#
# Usage:
#  ./path/to/update-version.sh [old_version] [new_version]
#
# Refer to the README.md file for information about the different options
#
# Requires composer and git
#
################################################################################

while (( "$#" )); do
	package="$1"

	# If the package name doesn't include version then skip it.
	if [[ $package != *":"* ]]; then
		echo "$package doesn't have version. Skipping.."
		shift
		continue
	fi

	# If the package name doesn't include vendor prefix then assume it is wpackagist-plugin/
	if [[ $package != *"/"* ]]; then
		package="wpackagist-plugin/$1"
	fi

	# Update the package
	composer require $package

	plugin=${package%:*}
	plugin=${plugin#*/}
	version=${package#*:}

	git add composer.json composer.lock
	git commit -m "Update $plugin to v$version"
	shift
done
