#!/bin/bash

################################################################################
# Creates a zip file of the Plugin
# Author: Sudar <http://sudarmuthu.com>
#
# License: Beerware ;)
#
# You should invoke this script from the Plugin directory, but you don't need
# to copy this script to every Plugin directory. You can just have one copy
# somewhere and then invoke it from multiple Plugin directories.
#
# Usage:
#  ./path/to/create-archive.sh [-p plugin-name] [-o output-dir]
#
# Refer to the README.md file for information about the different options
#
################################################################################
OUTPUT_DIR="$HOME/Downloads"
PLUGIN_NAME=${PWD##*/}

# Get the directory in which this shell script is present
cd $(dirname "${0}") > /dev/null
SCRIPT_DIR=$(pwd -L)
cd - > /dev/null

# Readme converter
README_CONVERTER=$SCRIPT_DIR/readme-converter.sh

README_MD=`find . -iname "readme.md"`

# lifted this code from http://www.shelldorado.com/goodcoding/cmdargs.html
while [ $# -gt 0 ]
do
    case "$1" in
        -p)  PLUGIN_NAME="$2"; shift;;
        -o)  OUTPUT_DIR="$2"; shift;;
        -*)
            echo >&2 \
            "usage: $0 [-p plugin-name] [-o output-dir]"
            exit 1;;
        *)  break;;	# terminate while loop
    esac
    shift
done

LATEST_TAG=`git describe --abbrev=0`
if [ $? -eq 0 ]; then
    echo "[Info] The latest tag is : $LATEST_TAG"
    LATEST_TAG="-$LATEST_TAG"
else
    echo "[Info] No latest tag found"
    LATEST_TAG=""
fi

# Convert markdown in readme.md file to WordPress readme.txt format
if [ -f "$README_MD" ]; then
    echo "[Info] Convert readme file into WordPress format"
    $README_CONVERTER $README_MD readme.txt to-wp
fi

git archive --format zip --prefix $PLUGIN_NAME/ --output $OUTPUT_DIR/${PLUGIN_NAME}${LATEST_TAG}.zip master

zip -d $OUTPUT_DIR/${PLUGIN_NAME}${LATEST_TAG}.zip ${PLUGIN_NAME}/README.md
cd ../
zip $OUTPUT_DIR/${PLUGIN_NAME}${LATEST_TAG}.zip ${PLUGIN_NAME}/readme.txt
rm ${PLUGIN_NAME}/readme.txt

echo "[Info] Zip file created at $OUTPUT_DIR/${PLUGIN_NAME}${LATEST_TAG}.zip"
