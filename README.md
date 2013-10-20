What is this?
=============

Collection of bash scripts that I am using to manage and deploy my [WordPress Plugins](http://sudarmuthu.com/wordpress) from GitHub into WordPress official repository svn.

Make sure you have `git-svn` installed. In Ubuntu you can do `sudo apt-get install git-svn`

- clone-from-svn-to-git.sh - Use this script to clone your WordPress Plugins from SVN into git/github
- deploy-plugin.sh - Use this script to push your WordPress Plugin updates to SVN from git/github
- readme-convertor.sh - Use this script to convert readme files between Github markdown and WordPress repo markdown format
- create-archive.sh - Use this script to create a zip archive of the Plugin

Usage
-------------

### Cloning existing Plugins from SVN into github

You can use the `clone-from-svn-to-git.sh` script to clone an existing Plugin from the official WordPress repository SVN into github.

`.path/to/clone-from-svn-to-git.sh [-p plugin-name] [-a authors-file] [-u svn-username] [-g github-repo-url]`

The following are the different options that you can pass to this script.

- `-p` - The name of the Plugin
- `-a` - The path to the authors file. You can find a sample authors file in the root directory of the repo.
- `-u` - The svn username. It is same as your WordPress Plugin repo username.
- `-g` - The url to the github repo. You should have push rights to this repo.

### Deploying to SVN repo from Github

You can use the `deploy-plugin.sh` script to deploy your Plugins to SVN repo, from a git repo.

You don't need to have a copy of this script in every repo. You just need to have one copy of this script somewhere and then you can invoke it from multiple Plugin directories using the following options.

`./path/to/deploy-plugin.sh [-p plugin-name] [-u svn-username] [-m main-plugin-file] [-a assets-dir-name] [-t tmp directory] [-i path/to/i18n]`

The following are the different options that you can pass to this script.

- `-p` - The name of the Plugin. The script can pick it up from the current directory name
- `-u` - The svn username. It is same as your WordPress Plugin repo username.
- `-m` - The name of the main Plugin file. By default it is `plugin-name.php`
- `-a` - The name of the Plugin's assets directory. By default it is assumed to be `assets-wp-repo`
- `-t` - Path to the temporary directory. By default `/tmp` is used
- `-i` - Path to the WordPress i18n tools directory. By default `../i18n` is used. You have to checkout a local copy of the i18n tools from http://i18n.svn.wordpress.org/tools/trunk/

### Convert readme file from md to txt format and vice versa

You can use the `readme-convertor.sh` script to convert the readme file between WordPress Plugin format and github markdown format. The `deploy-script.sh` script automatically does the conversion by using this script.

`./path/to/readme-convertor.sh [from-file] [to-file] [format to-wp|from-wp]`

The following are the different options that you can pass to this script.

- The first parameter is the path to the input file
- The second parameter is the path to the output file
- The third parameter specifies the format. You can use one of the following two.
    - `to-wp` - convert from Github markdown format to WordPress Plugin Readme format
    - `from-wp` - convert from WordPress Plugin Readme format to Github markdown format

### Creating a zip archive of the Plugin

You can use the `create-archive.sh` script to quickly create a zip archive of the Plugin.

`./path/to/create-archive.sh [-p plugin-name] [-o output-dir]`

The following are the different options that you can pass to this script.

- `-p` - The name of the Plugin. The script can pick it up from the current directory name
- `-o` - Path to the output directory, where the zip file should be created

Code Quality Status
-------------------

The code is pretty stable and I currently use these script for deploying my [WordPress Plugins](http://sudarmuthu.com/wordpress) without any major issues. I would however consider the code to be of beta quality status.

Contribution
-------------
All contributions (even documentation) are welcome :)

If you would like to contribute to this project, then just fork it in github and send a pull request.

If you are looking for ideas, then you can start with the below TODO list.

TODO
-------------

Here is the list of things that I want to implement. Pull requests are welcome :)

- Delete files from svn that have been removed in the directory
- Ability to automatically show screenshots
- Find ways to speed up things in the clone script
- Add batch support in the clone script
- <del>Ability to auto update and generate .pot files</del>
- <del>In the deploy script, add support for assets/ folder</del>
- <del>In the deploy script, checkout only the trunk/ for the Plugin from svn</del>
- <del>Make the readme.txt <-> readme.md translation better, so that Plugin readme files appear good in github.</del>

License
-------

The source code and the config files are released under "THE BEER-WARE" license.

I would, however, consider it a great courtesy if you could email me and tell me about your project and how this code was used, just for my own continued personal gratification :)

You can also find other ways to [make me happy](http://sudarmuthu.com/if-you-wanna-thank-me), if you liked this project ;)
