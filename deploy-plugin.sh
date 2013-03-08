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
SVNUSER="sudar" # your svn username
TMPDIR="/tmp"
CURRENTDIR=`pwd`
COMMITMSG_FILE='wp-plugin-commit-msg.tmp'

# lifted this code from http://www.shelldorado.com/goodcoding/cmdargs.html
while [ $# -gt 0 ]
do
    case "$1" in
        -p)  PLUGINSLUG="$2"; MAINFILE="$PLUGINSLUG.php"; shift;;
        -u)  SVNUSER="$2"; shift;;
        -f)  MAINFILE="$2"; shift;;
        -t)  TMPDIR="$2"; shift;;
        -*)
            echo >&2 \
            "usage: $0 [-p plugin-name] [-u svn-username] [-m main-plugin-file] [-t tmp directory]"
            exit 1;;
        *)  break;;	# terminate while loop
    esac
    shift
done

# git config
GITPATH="$CURRENTDIR" # this file should be in the base of your git repository

# svn config
SVNPATH="$TMPDIR/$PLUGINSLUG" # path to a temp SVN repo. No trailing slash required and don't add trunk.
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
    NEWVERSION1=`grep "^Stable tag:" $GITPATH/readme.md | tr -d '\015' |awk -F' ' '{print $NF}'`
else
    NEWVERSION1=`grep "^Stable tag:" $GITPATH/readme.txt | tr -d '\015' |awk -F' ' '{print $NF}'`
fi

echo "[Info] readme.txt/md version: $NEWVERSION1"

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

# rename the .md file
mv readme.md readme.txt

# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add

# Get aggregated commit msg
COMMITMSG=`cat $TMPDIR/$COMMITMSG_FILE`
rm $TMPDIR/$COMMITMSG_FILE
svn commit --username=$SVNUSER -m "$COMMITMSG"

echo "[Info] Creating new SVN tag & committing it"
svn copy . $SVNURL/tags/$NEWVERSION1/ -m "Tagging version $NEWVERSION1"

echo "[Info] Removing temporary directory $SVNPATH"
rm -fr $SVNPATH/

echo "*** Done ***"
