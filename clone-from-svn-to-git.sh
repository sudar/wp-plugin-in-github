#!/bin/bash

# Clone the svn Plugin repo into github
# Author: Sudar <http://sudarmuthu.com>
#
# License: Beerware ;)
#
# Make sure you have git-svn installed. In ubuntu you can do sudo apt-get install git-svn

# TODO: Add support for giving a list of Plugin names

# default configurations
PLUGIN_NAME="posts-by-tag"
AUTHORS_FILE="/home/sudar/Dropbox/code/wp/wp-plugin-in-github/authors.txt"
SVN_USERNAME="sudar"
GITHUB_REPO="git@github.com:$SVN_USERNAME/$PLUGIN_NAME.git"

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

# Get the first revision number when this Plugin was checked in first
REVISION=$(svn log -r 1:HEAD --limit 1 http://plugins.svn.wordpress.org/$PLUGIN_NAME | awk 'NR==2{print $1;exit;}')
echo ">>>Plugin was first checked in at revision: $REVISION"

git svn clone -s -$REVISION -A $AUTHORS_FILE --no-minimize-url --username=$SVN_USERNAME http://plugins.svn.wordpress.org/$PLUGIN_NAME
echo ">>>Repo cloned. Let's fetch it"

cd $PLUGIN_NAME
git svn fetch
git rebase trunk
echo ">>>Fetched the content from svn. Adding repo to github"

git remote add origin $GITHUB_REPO

git mv readme.txt readme.md
git ci -am "Renamed readme.txt to readme.md, so that github can parse it"

git push -u origin master

echo ">>>Done"
