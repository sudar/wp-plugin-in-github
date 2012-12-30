#!/bin/bash

# Deploy WordPress Plugin to svn from Github
# Author: Sudar <http://sudarmuthu.com>
#
# License: Beerware ;)
#
# Make sure you have git-svn installed. In ubuntu you can do sudo apt-get install git-svn
# 
# Credit: Uses most of the code from the following places
#       https://github.com/deanc/wordpress-plugin-git-svn
#       https://github.com/thenbrent/multisite-user-management/blob/master/deploy.sh

# default configurations
PLUGINSLUG="bulk-delete"
MAINFILE="$PLUGINSLUG.php" # this should be the name of your main php file in the WordPress Plugin
SVNUSER="sudar" # your svn username
TMPDIR="/tmp"
CURRENTDIR=`pwd`

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

echo "readme.txt/md version: $NEWVERSION1"

NEWVERSION2=`grep "^Version:" $GITPATH/$MAINFILE | tr -d '\015' |awk -F' ' '{print $NF}'`
echo "$MAINFILE version: $NEWVERSION2"

if [ "$NEWVERSION1" != "$NEWVERSION2" ]; then echo "Version in readme.txt/md & $MAINFILE don't match. Exiting...."; exit 1; fi

echo "Versions match in readme.txt/md and $MAINFILE. Let's proceed..."

if git show-ref --tags --quiet --verify -- "refs/tags/$NEWVERSION1"
	then 
		echo "Version $NEWVERSION1 already exists as git tag. Exiting...."; 
		exit 1; 
	else
		echo "Git version does not exist. Let's proceed..."
fi

echo -e "Enter a commit message for this new version: \c"
read COMMITMSG

# if unsaved changes are there the commit them.
if ! git diff-index --quiet HEAD --; then
    echo "Unsaved changes found. Committing them to git"
    git commit -am "$COMMITMSG"
fi

# Tag new version 
echo "Tagging new version in git with $NEWVERSION1"
git tag -a "$NEWVERSION1" -m "Tagging version $NEWVERSION1"

echo "Pushing latest commit to origin, with tags"
git push origin master
git push origin master --tags

echo 
echo "Creating local copy of SVN repo ..."
svn co $SVNURL $SVNPATH

# TODO: Don't checkout trunk
echo "Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNPATH/trunk/

echo "Ignoring github specific files and deployment script"
svn propset svn:ignore "deploy.sh
README.md
.git
.gitignore" "$SVNPATH/trunk/"

echo "Changing directory to SVN and committing to trunk"
cd $SVNPATH/trunk/

# rename the .md file
mv readme.md readme.txt

# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
svn commit --username=$SVNUSER -m "$COMMITMSG"

echo "Creating new SVN tag & committing it"
cd $SVNPATH
svn copy trunk/ tags/$NEWVERSION1/
cd $SVNPATH/tags/$NEWVERSION1
svn commit --username=$SVNUSER -m "Tagging version $NEWVERSION1"

echo "Removing temporary directory $SVNPATH"
rm -fr $SVNPATH/

echo "*** Done ***"
