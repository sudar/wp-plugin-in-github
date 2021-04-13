What is this?
=============

Collection of bash scripts that I am using to manage and deploy my [WordPress Plugins](https://sudarmuthu.com/wordpress) from GitHub into WordPress official repository svn.

Make sure you have `git-svn` installed. In Ubuntu you can do `sudo apt-get install git-svn`

- clone-from-svn-to-git.sh - Use this script to clone your WordPress Plugins from SVN into git/github
- deploy-plugin.sh - Use this script to push your WordPress Plugin updates to SVN from git/github
- readme-converter.sh - Use this script to convert readme files between Github markdown and WordPress repo markdown format
- create-archive.sh - Use this script to create a zip archive of the Plugin
- update-version.sh - Use this script to update version string in all the files of the Plugin

Installation
-------------

There are two ways by which you can install the scripts.

- Clone the git repo to your local machine and then add the path to the repo to your `PATH` variable (or)
- Execute the following commands in your terminal

```
cd /tmp
git clone https://github.com/sudar/wp-plugin-in-github
chmod +x ./wp-plugin-in-github/*.sh
mv ./wp-plugin-in-github/*.sh /usr/local/bin/
rm -r ./wp-plugin-in-github
```

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

```
./path/to/deploy-plugin.sh [-p plugin-name] [-u svn-username] [-m main-plugin-file]
        [-a assets-dir-name] [-t tmp directory] [-i make-pot-command] [-h history/changelog file]
        [-r] [-b build-command]
```

The following are the different options that you can pass to this script.

- `-p` - The name of the Plugin. The script can pick it up from the current directory name
- `-u` - The svn username. It is same as your WordPress Plugin repo username.
- `-m` - The name of the main Plugin file. By default, it is `plugin-name.php`
- `-a` - The name of the Plugin's assets directory. By default, it is assumed to be `assets-wp-repo`
- `-t` - Path to the temporary directory. By default `/tmp` is used
- `-i` - Command to generate pot file.
- `-h` - The name of the History or changelog file. By default `HISTORY.md` is used.
- `-r` - Whether build command should be run. By default `npm run dist` is called.
- `-b` - Override build command. This command should place the final files in `/dist` directory.

### Convert readme file from md to txt format and vice versa

You can use the `readme-converter.sh` script to convert the readme file between WordPress Plugin format and github markdown format. This script also handles screenshots as well.

The `deploy-script.sh` script automatically does the conversion by using this script.

`./path/to/readme-converter.sh [from-file] [to-file] [format to-wp|from-wp]`

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

### Update version string of the Plugin

You can use the `update-version.sh` script to quickly update the version string of all the files of the Plugin.

`./path/to/update-version.sh [old_version] [new_version]`

The following are the different options that you can pass to this script.

- `old_version` - Old version string. This string should be escaped. eg: 1\.2\.3 and not 1.2.3
- `new_version` - New version string. You don't have to escape this

Code Quality Status
-------------------

The code is pretty stable and I currently use these script for deploying my [WordPress Plugins](http://sudarmuthu.com/wordpress) without any major issues. I would however consider the code to be of beta quality status.

Contribution
-------------
All contributions (even documentation) are welcome :)

If you would like to contribute to this project, then just fork it in github and send a pull request.

If you are looking for ideas, then you can start with the below TODO list.

TODO
----

Here is the list of things that I want to implement. Pull requests are welcome :)

- Add an option to exclude certain files/folders from svn ([issue #20](https://github.com/sudar/wp-plugin-in-github/issues/20))
- If a repo has git submodules then the files from submodules are not getting included in the svn check-in ([issue #17](https://github.com/sudar/wp-plugin-in-github/issues/17))
- Delete files from svn that have been removed from git ([issue #8](https://github.com/sudar/wp-plugin-in-github/issues/8))
- Provide an option to specify the list of files that should be ignored while replacing version string ([issue #14](https://github.com/sudar/wp-plugin-in-github/issues/14))
- Add batch support in the clone script
- <del>Find ways to speed up things in the clone script</del>
- <del>Ability to automatically show screenshots</del>
- <del>Ability to auto update and generate .pot files</del>
- <del>In the deploy script, add support for assets/ folder</del>
- <del>In the deploy script, checkout only the trunk/ for the Plugin from svn</del>
- <del>Make the readme.txt <-> readme.md translation better, so that Plugin readme files appear good in github.</del>

License
-------

The source code and the config files are released under "THE BEER-WARE" license.

I would, however, consider it a great courtesy if you could email me and tell me about your project and how this code was used, just for my own continued personal gratification :)

You can also find other ways to [make me happy](http://sudarmuthu.com/if-you-wanna-thank-me), if you liked this project ;)
