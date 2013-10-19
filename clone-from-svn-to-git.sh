#!/bin/bash

################################################################################
# Clone the svn Plugin repo into github
# Author: Sudar <http://sudarmuthu.com>
#
# License: Beerware ;)
#
# Usage:
# ./path/to/clone-from-svn-to-git.sh [-p plugin-name] [-a authors-file] [-u svn-username] [-g github-repo-url]`
#
# Refer to the README.md file for information about the different options
#
# Make sure you have git-svn installed. In ubuntu you can do sudo apt-get install git-svn
################################################################################

# TODO: Add support for giving a list of Plugin names

# Get the directory in which this shell script is present
cd $(dirname "${0}") > /dev/null
SCRIPT_DIR=$(pwd -L)
cd - > /dev/null

# default configurations
PLUGIN_NAME="posts-by-tag"
AUTHORS_FILE="$SCRIPT_DIR/authors.txt"
SVN_USERNAME="sudar"

# Readme converter 
README_CONVERTER=$SCRIPT_DIR/readme-converter.sh

# lifted this code from http://www.shelldorado.com/goodcoding/cmdargs.html
while [ $# -gt 0 ]
do
    case "$1" in
        -p)  PLUGIN_NAME="$2"; shift;;
        -a)  AUTHORS_FILE="$2"; shift;;
        -u)  SVN_USERNAME="$2"; shift;;
        -g)  GITHUB_REPO="$2"; shift;;
        -*)
            echo >&2 \
            "usage: $0 [-p plugin-name] [-a authors-file] [-u svn-username] [-g github-repo-url]"
            exit 1;;
        *)  break;;	# terminate while loop
    esac
    shift
done

if [ -z "$GITHUB_REPO" ]; then
    GITHUB_REPO="git@github.com:$SVN_USERNAME/$PLUGIN_NAME.git"
fi

# Get the first revision number when this Plugin was checked in first
REVISION=$(svn log -r 1:HEAD --limit 1 http://plugins.svn.wordpress.org/$PLUGIN_NAME | awk 'NR==2{print $1;exit;}')
echo "[Info] Plugin was first checked in at revision: $REVISION"

git svn clone -s -$REVISION -A $AUTHORS_FILE --no-minimize-url --username=$SVN_USERNAME http://plugins.svn.wordpress.org/$PLUGIN_NAME
echo "[Info] Repo cloned. Let's fetch it"

cd $PLUGIN_NAME
git svn fetch
git rebase trunk
echo "[Info] Fetched the content from svn. Adding repo to github"

git remote add origin $GITHUB_REPO

# Convert markdown in readme.txt file to github markdown format
echo "[Info] Convert readme file into WordPress format"
$README_CONVERTER readme.txt readme.md from-wp

git ci -am "Renamed readme.txt to readme.md, so that github can parse it"

git push -u origin master

echo "[Info] Done"
