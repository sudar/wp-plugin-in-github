#!/bin/bash

################################################################################
# Deploy WordPress Plugin to svn from Github
# Author: Sudar <http://sudarmuthu.com>
#
# License: Beerware ;)
#
# You should invoke this script from the Plugin directory, but you don't need 
# to copy this script to every Plugin directory. You can just have one copy 
# somewhere and then invoke it from multiple Plugin directories.
#
# Usage:
#  ./path/to/deply-plugin.sh [-p plugin-name] [-u svn-username] [-m main-plugin-file] [-a assets-dir-name] [-t tmp directory] [-i path/to/i18n]
#
# Refer to the README.md file for information about the different options
# 
# Credit: Uses most of the code from the following places
#       https://github.com/deanc/wordpress-plugin-git-svn
#       https://github.com/thenbrent/multisite-user-management/blob/master/deploy.sh
#       https://github.com/ocean90/svn2git-tools/
################################################################################

# default configurations
PLUGINSLUG=${PWD##*/}                    # The name of the Plugin. By default the directory name is used
MAINFILE="$PLUGINSLUG.php"               # this should be the name of your main php file in the WordPress Plugin
ASSETS_DIR="assets-wp-repo"              # the name of the assets directory that you are using
SVNUSER="sudar"                          # your svn username
TMPDIR="/tmp"                            # temp directory path
CURRENTDIR=`pwd`
COMMIT_MSG_FILE='wp-plugin-commit-msg.tmp'

# Get the directory in which this shell script is present
cd $(dirname "${0}") > /dev/null
SCRIPT_DIR=$(pwd -L)
cd - > /dev/null

# WordPress i18n path. You can check it out from http://i18n.svn.wordpress.org/tools/trunk/
I18N_PATH=$SCRIPT_DIR/../i18n

# Readme converter 
README_CONVERTER=$SCRIPT_DIR/readme-converter.sh

# lifted this code from http://www.shelldorado.com/goodcoding/cmdargs.html
while [ $# -gt 0 ]
do
    case "$1" in
        -p)  PLUGINSLUG="$2"; MAINFILE="$PLUGINSLUG.php"; shift;;
        -u)  SVNUSER="$2"; shift;;
        -m)  MAINFILE="$2"; shift;;
        -a)  ASSETS_DIR="$2"; shift;;
        -i)  I18N_PATH="$2"; shift;;
        -t)  TMPDIR="$2"; shift;;
        -*)
            echo >&2 \
            "usage: $0 [-p plugin-name] [-u svn-username] [-m main-plugin-file] [-a assets-dir-name] [-t tmp directory] [-i path/to/i18n]"
            exit 1;;
        *)  break;;	# terminate while loop
    esac
    shift
done

# git config
GITPATH="$CURRENTDIR"

# svn config
SVNPATH="$TMPDIR/$PLUGINSLUG" # path to a temp SVN repo. No trailing slash required and don't add trunk.
SVNPATH_ASSETS="$TMPDIR/$PLUGINSLUG-assets" # path to a temp assets directory.
SVNURL="http://plugins.svn.wordpress.org/$PLUGINSLUG/" # Remote SVN repo on wordpress.org

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
    NEWVERSION1=`awk -F' ' '/Stable tag:/{print $3}' $GITPATH/readme.md | tr -d '\r '`
else
    NEWVERSION1=`awk -F' ' '/Stable tag:/{print $3}' $GITPATH/readme.txt | tr -d '\r '`
fi

echo "[Info] readme.txt/md version: $NEWVERSION1"

NEWVERSION2=`awk -F' ' '/^Version:/{print $NF}' $GITPATH/$MAINFILE | tr -d '\r'`
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
    read COMMIT_MSG

    git commit -am "$COMMIT_MSG"
fi

# Retrieve commit messages till the last tag
git log `git describe --tags --abbrev=0`..HEAD --oneline > $TMPDIR/$COMMIT_MSG_FILE

echo 
# the text domain used for translation
TEXTDOMAIN=`awk -F' ' '/^Text Domain:/{print $NF}' $GITPATH/$MAINFILE | tr -d '\r'`
if [ -z "$TEXTDOMAIN" ]; then
    TEXTDOMAIN="$PLUGINSLUG"                 
    echo "[Info] Text Domain not found in $MAINFILE. Assuming the '$PLUGINSLUG' as Text Domain"
else
    echo "[Info] Text Domain found in $MAINFILE: $TEXTDOMAIN"
fi

# The path the pot file has to be stored
POT_FILEPATH=`awk -F' ' '/^Domain Path:/{print $NF}' $GITPATH/$MAINFILE | tr -d '\r'`
if [ -z "$POT_FILEPATH" ]; then
    POT_FILEPATH="languages/"                
    echo "[Info] Text Domain path not found in $MAINFILE. Assuming the '$POT_FILEPATH' as path"
else
    echo "[Info] Text Domain path found in $MAINFILE: '$POT_FILEPATH'"
fi

# Add textdomain to all php files
echo "[Info] Adding text domain to all PHP files"
find . -iname "*.php" -type f -print0 | xargs -0 -n1 php $I18N_PATH/add-textdomain.php -i $TEXTDOMAIN

# Regenerate pot file
echo "[Info] Regenerating pot file"
php $I18N_PATH/makepot.php wp-plugin . ${POT_FILEPATH}${TEXTDOMAIN}.pot

# commit .pot file and textdomain changes
DEFAULT_POT_COMMIT_MSG="Regenerate pot file for v$NEWVERSION1" # Default commit msg after generating a new pot file
if ! git diff-index --quiet HEAD --; then
    echo "[Info] Textdomain/.pot file changes found. Committing them to git"
    echo -e "Enter a commit message (Default: $DEFAULT_POT_COMMIT_MSG) : \c"
    read POT_COMMIT_MSG

    if [ -z "$POT_COMMIT_MSG" ]; then
        POT_COMMIT_MSG=$DEFAULT_POT_COMMIT_MSG
    fi

    git commit -am "$POT_COMMIT_MSG"
fi

echo 
# Tag new version 
echo "[Info] Tagging new version in git with $NEWVERSION1"
git tag -a "$NEWVERSION1" -m "Tagging version $NEWVERSION1"

# Push the latest version to github
echo "[Info] Pushing latest commit to origin, with tags"
git push origin master
git push origin master --tags

echo 
# Process /assets directory
if [ -d $GITPATH/$ASSETS_DIR ]; then
    echo "[Info] Assets directory found. Processing it."

    if svn checkout $SVNURL/assets $SVNPATH_ASSETS; then
        echo "[Info] Assets directory is checked out to: $SVNPATH_ASSETS"
    else
        echo "[Info] Assets directory is not found in SVN. Creating it."
        # /assets directory is not found in SVN, so let's create it.
        # Create the assets directory and check-in. 
        # I am doing this for the first time, so that we don't have to checkout the entire Plugin directory, every time we run this script.
        # Since it takes lot of time, especially if the Plugin has lot of tags
        svn checkout $SVNURL $TMPDIR/$PLUGINSLUG
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
    if [ $? -eq 0 ]; then
            svn status | grep "^?" | awk '{print $2}' | xargs svn add # Add new assets
            # TODO: Delete files that have been removed from assets directory
            svn commit --username=$SVNUSER -m "Updated assets"
            echo "[Info] Assets committed to SVN."
        else
            echo "[Info] Contents of Assets directory unchanged. Ignoring it."
    fi

    # Let's remove the assets directory in /tmp which is not needed any more
    rm -rf $SVNPATH_ASSETS

    cd $GITPATH
else
    echo "[Info] No assets directory found."
fi

echo 
echo "[Info] Creating local copy of SVN repo ..."
svn co $SVNURL/trunk $SVNPATH

echo "[Info] Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNPATH/

echo "[Info] Ignoring github specific files and deployment script"
# There is no simple way to exclude readme.md. http://stackoverflow.com/q/16066485/24949
svn propset svn:ignore "[Rr][Ee][Aa][Dd][Mm][Ee].[Mm][Dd]
.git
$ASSETS_DIR
.gitignore" "$SVNPATH"

echo "[Info] Changing directory to SVN and committing to trunk"
cd $SVNPATH

# remove assets directory if found
if [ -d $ASSETS_DIR ]; then
    rm -rf $ASSETS_DIR
fi

# Convert markdown in readme.txt file to github markdown format
echo "[Info] Convert readme file into WordPress format"
$README_CONVERTER readme.md readme.txt to-wp

# TODO: Handle screenshots as well
# TODO: Delete files from svn that have been removed 

# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" && svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add

# Get aggregated commit msg and add comma in between them
COMMIT_MSG=`cut -d' ' -f2- $TMPDIR/$COMMIT_MSG_FILE | sed -e '$ ! s/$/,/'`
rm $TMPDIR/$COMMIT_MSG_FILE

if [ -z "$COMMIT_MSG" ]; then
    echo "[Info] Couldn't automatically get commit message."
    echo -e "Enter a commit message : \c"
    read COMMIT_MSG
fi

svn commit --username=$SVNUSER -m "$COMMIT_MSG"

echo "[Info] Creating new SVN tag & committing it"
svn copy . $SVNURL/tags/$NEWVERSION1/ -m "Tagging v$NEWVERSION1 for release"

echo "[Info] Removing temporary directory $SVNPATH"
rm -fr $SVNPATH/

echo "[Info] Done"
