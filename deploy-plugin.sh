#!/bin/bash

# Deploy WordPress Plugin to svn from Github
# Author: Sudar <http://sudarmuthu.com>
#
# License: Beerware ;)
#
# Make sure you have git-svn installed. In Ubuntu you can do sudo apt-get install git-svn
# 
# Credit: Uses most of the code from the following places
#       https://github.com/deanc/wordpress-plugin-git-svn
#       https://github.com/thenbrent/multisite-user-management/blob/master/deploy.sh
#       https://github.com/ocean90/svn2git-tools/

# default configurations
PLUGINSLUG="bulk-delete"
MAINFILE="$PLUGINSLUG.php" # this should be the name of your main php file in the WordPress Plugin
ASSETS_DIR="assets-wp-repo" # the name of the assets directory that you are using
SVNUSER="sudar" # your svn username
TMPDIR="/tmp"
CURRENTDIR=`pwd`
COMMITMSG_FILE='wp-plugin-commit-msg.tmp'

# Get the directory in which this shell script is present
cd $(dirname "${0}") > /dev/null
SCRIPT_DIR=$(pwd -L)
cd - > /dev/null

# Readme converter 
README_CONVERTOR=$SCRIPT_DIR/readme-convertor.sh

# lifted this code from http://www.shelldorado.com/goodcoding/cmdargs.html
while [ $# -gt 0 ]
do
    case "$1" in
        -p)  PLUGINSLUG="$2"; MAINFILE="$PLUGINSLUG.php"; shift;;
        -u)  SVNUSER="$2"; shift;;
        -f)  MAINFILE="$2"; shift;;
        -a)  ASSETS_DIR="$2"; shift;;
        -t)  TMPDIR="$2"; shift;;
        -*)
            echo >&2 \
            "usage: $0 [-p plugin-name] [-u svn-username] [-m main-plugin-file] [-a assets-dir-name] [-t tmp directory]"
            exit 1;;
        *)  break;;	# terminate while loop
    esac
    shift
done

# git config
GITPATH="$CURRENTDIR" # this file should be in the base of your git repository

# svn config
SVNPATH="$TMPDIR/$PLUGINSLUG" # path to a temp SVN repo. No trailing slash required and don't add trunk.
SVNPATH_ASSETS="$TMPDIR/$PLUGINSLUG-assets" # path to a temp assets directory.
SVNURL="http://plugins.svn.wordpress.org/$PLUGINSLUG/" # Remote SVN repo on wordpress.org, with no trailing slash

cd $GITPATH

# Let's begin...
echo ".........................................."
echo 
echo "Preparing to deploy WordPress Plugin"
echo 
echo ".........................................."
echo 

# Pull the latest changes from origin, to make sure we are using the latest code
git pull origin master

# Check version in readme.txt/md is the same as plugin file
# if readme.md file is found, then use it
if [ -f "$GITPATH/readme.md" ]; then
    NEWVERSION1=`awk -F' ' '/Stable tag:/{print $NF}' $GITPATH/readme.md | tr -d '\r'`
else
    NEWVERSION1=`awk -F' ' '/Stable tag:/{print $NF}' $GITPATH/readme.txt | tr -d '\r'`
fi

echo "[Info] readme.txt/md version: $NEWVERSION1"

NEWVERSION2=`awk -F' ' '/^Version:/{print $NF}' $GITPATH/$MAINFILE | tr -d '\r'`
NEWVERSION2=`grep "^Version:" $GITPATH/$MAINFILE | tr -d '\015' |awk -F' ' '{print $NF}'`
echo "[Info] $MAINFILE version: $NEWVERSION2"

if [ "$NEWVERSION1" != "$NEWVERSION2" ]; then echo "Version in readme.txt/md & $MAINFILE don't match. Exiting...."; exit 1; fi

echo "[Info] Versions match in readme.txt/md and $MAINFILE. Let's proceed..."

if git show-ref --tags --quiet --verify -- "refs/tags/$NEWVERSION1"
	then 
		echo "Version $NEWVERSION1 already exists as git tag. Exiting...."; 
		exit 1; 
	else
		echo "[Info] Git version does not exist. Let's proceed..."
fi

# if unsaved changes are there the commit them.
if ! git diff-index --quiet HEAD --; then
    echo "[Info] Unsaved changes found. Committing them to git"
    echo -e "Enter a commit message for unsaved changes: \c"
    read COMMITMSG

    git commit -am "$COMMITMSG"
fi

# Retrieve commit messages till the last tag
git log `git describe --tags --abbrev=0`..HEAD --oneline > $TMPDIR/$COMMITMSG_FILE

# Tag new version 
echo "[Info] Tagging new version in git with $NEWVERSION1"
git tag -a "$NEWVERSION1" -m "Tagging version $NEWVERSION1"

# Push the latest version to github
echo "[Info] Pushing latest commit to origin, with tags"
git push origin master
git push origin master --tags

# Process /assets directory
if [ -d $GITPATH/$ASSETS_DIR ]
	then
        echo "[Info] Assets directory found. Processing it."
		if svn checkout $SVNURL/assets $SVNPATH_ASSETS; then
		    echo "[Info] Assets directory is not found in SVN. Creating it."
		    # /assets directory is not found in SVN, so let's create it.
		    # Create the assets directory and check-in. 
		    # I am doing this for the first time, so that we don't have to checkout the entire Plugin directory, every time we run this script.
		    # Since it takes lot of time, especially if the Plugin has lot of tags
            svn checkout $SVNURL $TMPDIR
            cd $TMPDIR/$PLUGINSLUG
            mkdir assets
            svn add assets
            svn commit -m "Created the assets directory in SVN"
            rm -rf $TMPDIR/$PLUGINSLUG
            svn checkout $SVNURL/assets $SVNPATH_ASSETS
        fi

		cp $GITPATH/$ASSETS_DIR/* $SVNPATH_ASSETS # copy assets
		cd $SVNPATH_ASSETS # Switch to assets directory
		svn status | grep "^?\|^M" > /dev/null 2>&1 # Check if new or updated assets exists
		if [ $? -eq 0 ]
			then
				svn status | grep "^?" | awk '{print $2}' | xargs svn add # Add new assets
				svn commit --username=$SVNUSER -m "Updated assets"
				echo "[Info] Assets committed to SVN."
				rm -rf $SVNPATH_ASSETS
			else
				echo "[Info] Contents of Assets directory unchanged. Ignoring it."
		fi
	else
		echo "[Info] No assets directory found."
fi

echo 
echo "[Info] Creating local copy of SVN repo ..."
svn co $SVNURL/trunk $SVNPATH

echo "[Info] Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNPATH/

echo "[Info] Ignoring github specific files and deployment script"
svn propset svn:ignore "README.md
.git
.gitignore" "$SVNPATH"

echo "[Info] Changing directory to SVN and committing to trunk"
cd $SVNPATH

# remove assets directory if found
if [ -d $ASSETS_DIR ]; then
    rm -rf $ASSETS_DIR
fi

# Convert markdown in readme.txt file to github markdown format
$README_CONVERTOR readme.md readme.txt to-wp

# TODO: Generate .pot files as well

# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add

# Get aggregated commit msg and add comma in between them
COMMITMSG=`cut -d' ' -f2- $TMPDIR/$COMMITMSG_FILE | sed -e '$ ! s/$/,/'`
rm $TMPDIR/$COMMITMSG_FILE
svn commit --username=$SVNUSER -m "$COMMITMSG"

echo "[Info] Creating new SVN tag & committing it"
svn copy . $SVNURL/tags/$NEWVERSION1/ -m "Tagging version $NEWVERSION1"

echo "[Info] Removing temporary directory $SVNPATH"
rm -fr $SVNPATH/

echo "*** Done ***"
