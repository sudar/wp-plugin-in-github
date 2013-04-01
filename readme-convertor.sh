#!/bin/bash

# Convert files between WordPress Plugin readme and Github markdown format
# Author: Sudar <http://sudarmuthu.com>
#
# License: Beerware ;)
#
# Credit: Uses most of the code from the following places
#       https://github.com/ocean90/svn2git-tools/

# wrapper for sed
_sed() {
    # -E is used so that it is compatible in both Mac and Ubuntu.
	sed -E "$1" $2 > $2.tmp && mv $2.tmp $2
}

# WP to Markdown format
wptomarkdown () {
    if [ ! -f $1 ]; then
        echo "$1 doesn't exist"
        exit 1;
    fi

    cp $1 $2

    PLUGINMETA=("Contributors" "Donate link" "Donate Link" "Tags" "Requires at least" "Tested up to" "Stable tag" "License" "License URI")
    for m in "${PLUGINMETA[@]}"
    do
        _sed 's/^'"$m"':/**'"$m"':**/g' $2
    done

    _sed "s/===([^=]+)===/#\1#/g" $2
    _sed "s/==([^=]+)==/##\1##/g" $2
    _sed "s/=([^=]+)=/###\1###/g" $2
}

# Markdown to WP format
markdowntowp () {
    if [ ! -f $1 ]; then
        echo "$1 doesn't exist"
        exit 1;
    fi

    cp $1 $2

    PLUGINMETA=("Contributors" "Donate link" "Donate Link" "Tags" "Requires at least" "Tested up to" "Stable tag" "License" "License URI")
    for m in "${PLUGINMETA[@]}"
    do
        _sed 's/^\*\*'"$m"':\*\*/'"$m"':/g' $2
    done

    _sed "s/###([^#]+)###/=\1=/g" $2
    _sed "s/##([^#]+)##/==\1==/g" $2
    _sed "s/#([^#]+)#/===\1===/g" $2
}

if [ $# -eq 3 ]; then

    if [ "$3" == "to-wp" ]; then
        markdowntowp $1 $2
    else
        wptomarkdown $1 $2
    fi

else
        echo >&2 \
        "usage: $0 [from-file] [to-file] [format to-wp|from-wp]"

        exit 1;
fi
