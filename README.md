wp-plugin-in-gitbub
===================

Collection of bash scripts that I am using to manage and deploy my WordPress Plugins from github into WordPress official repository svn.

Make sure you have `git-svn` installed. In Ubuntu you can do `sudo apt-get install git-svn`

- clone-from-svn-to-git.sh - Use this script to clone your WordPress Plugins from SVN into git/github
- deploy-plugin.sh - Use this script to push your WordPress Plugin updates to SVN from gi/github
- readme-convertor.sh - Use this script to convert readme files between Github markdown and WordPress repo markdown format

Contribution
-------------
All contributions (even documentations) are welcome :)

If you would like to contribute to this project, then just fork it in github and send a pull request. 

If you are looking for ideas, then you can start with the below TODO list.

TODO
-------------

Here is the list of things that I want to implement. Pull requests are welcome :)

- [ ] Ability to auto update and generate .pot files
- [ ] Ability to automatically show screenshots
- [ ] Better documentation
- [ ] Find ways to speed up things in the clone script
- [ ] Add batch support in the clone script
- [x] In the deploy script, add support for assets/ folder
- [x] In the deploy script, checkout only the trunk/ for the Plugin from svn
- [x] Make the readme.txt <-> readme.md translation better, so that Plugin readme files appear good in github.

License
-------

The source code and the config files are released under "THE BEER-WARE" license.

I would, however, consider it a great courtesy if you could email me and tell me about your project and how this code was used, just for my own continued personal gratification :)

You can also find other ways to [make me happy](http://sudarmuthu.com/if-you-wanna-thank-me), if you liked this project ;)
