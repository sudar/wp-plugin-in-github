#!/bin/bash

################################################################################
# Update version number across all your plugin files

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
# Requires ack-grep and perl
#
# TODO: And an option to specify the list of files to ignore
#
################################################################################

# Ignores the following
#       - HISTORY.md
#       - All files inside /languages folder
#       - Any line that has the string `@string`

# Command line parameters
#       $1 - old version (String to be searched for, Should be escaped)
#       $2 - new version (String to be replaced with)

echo "[Info] Replacing $1 with $2"
ack --ignore-file=is:HISTORY.md --ignore-dir=languages -l --print0 "$1" | xargs -0 perl -pi -e "/\@since/ || s/$1/$2/g"

# See the difference
git status
git diff
