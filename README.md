# profile
This project aims to create an advanced bash profile. It includes some aliases,
a customized prompt and several functions for different purposes. It's mostly
targeted to system administrator but might satisfy some regular users.

## 1. Getting started
Download and extract (or use git clone) the profile archive into your home
directory. You will have to modify your ~/.bashrc and/or ~/.profile file to add
at the end (preferably):
```
source <installpath>/profile/profile.sh
```

It's not recommended to load that profile in /etc/profile as the users' .bashrc
files might interfere with some aliases and functions defined in profile.

## 2. What's the purpose?
profile is giving access to numerous functions, aliases and to an advanced
prompt. Here is a non-exhaustive list of what we have:
- A bar style prompt with hour, execution time and exit code of the last
command;
- clean: erase after confirmation any backup file, possibly recursively;
- dpkgs: search for the given pattern in the installed packages name;
- expandlist: usefull in scripts, it expand any expression using wildcards into
the corresponding list of file and directories;
- genpwd: generate one or more random secure password;
- gpid: give the list of PID matching the given process name;
- help: display the list of available function and basic use;
- isipv4: tell if the given parameter is a valid IPv4 address;
- isipv6: tell if the given parameter is a valid IPv6 address;
- ku: kill all the processes owned by the given user name or ID;
- mcd: create a directory and immediately move into it;
- meteo: display weather forecast information;
- ppg: look for the given patern in the running processes;
- rain: console screensaver with rain effect;
- rmhost: remove the given host (name or IP) to the list of SSH known host;
- rmspc: in the current directory it replace all the spaces in filenames with a
underscore caracter (or any other given in option);
- setc: set locale on standard C;
- setfr: set locale on French;
- settrace: allow the debugging of any script by showing a backtrace in case of
error;
- setus: set locale on US English;
- showinfo: display basic informations about the host;
- ssr: root ssh login to the given host;
- taz: a universal command to compress files and directories, possibly several
at once;
- utaz: a utility that smartly uncompress many archives at once, creating a
directory only if needed;
- ver: show profile version.

## 3. Configuration
Some functions might have configurable default behaviour. You can create a
.profile.conf file to configure those default behaviour. You should have a look
at the doc/.profile.conf.example to see the list of available options.

## 4. Contact and more information
### 4.1. New users
This project is very new in terms of publication, and I have no idea of who will
use it, if any does. If you use (or plan to use) ```profile```, I'll be very
happy if you simply mail me to let me know, especially if you don't plan to
contribute. If you plan to contribute, I'll be twice happier for sure!

### 4.2. Bugs
**profile** bug tracker is hosted on its Gitea instance. Check the
https://git.geoffray-levasseur.org/fatalerrors/profile page. If you find a bug,
you can also submit a bug report to the maintainer mail address mentioned at
the end of that document. A bug report may contain the command line parameters
where the bug happens, OS details, the module that trigger it, if any, and the
log file containing the error. Cygwin users: please note that bash
implementation in Cygwin triggers regularly bugs on advanced code that triggers
nothing with Linux or BSD. Please do not send synthax error bug repports if you
didn't test the same code in the same conditions using a real Unix.

Please check the to-do list before sending any feature request, as it might
have already be requested.

### 4.3. How to contribute?
You are free to improve and contribute as you wish. If you have no idea what to
do or want some direction, you can check the [to-do list](./doc/todo.md),
containing desired future improvements. Make sure you always have the latest
development version before starting your work.

It's heavily recommended to use git to obtain the latest copy of profile tree.
Make sure your git configuration is correct in order to contribute. Please
contact me to obtain push authorizations, or, if you want to submit a patch, you
can send it by mail to the maintainer of init.sh.

Code written in Python or Perl might be accepted as long as it's not mobilizing
a lot of dependencies (forget big framework). Anything that need the
installation of packages not provided in minimal Debian or CentOS installation
will be probably rejected.

If you want to make a financial contribution, please contact me by mail.

### 4.4. License, website, and maintainer
Everything except configuration files is licensed under BSD-3 license. Please
check license file allong this one.

Please check [https://www.geoffray-levasseur.org/profile](https://www.geoffray-levasseur.org/profile).
Note that this website is still under construction and needs some more care.

You can mail author to fatalerrors \<at\> geoffray-levasseur \<dot\> org.

-----------------------------------------------------------------------------

Documentation (c) 2021-2022 Geoffray Levasseur.

This file is distributed under3-clause BSD license. The complete license
agreement can be obtained at: https://opensource.org/licenses/BSD-3-Clause
