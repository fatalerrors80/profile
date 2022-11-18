#!/bin/bash
# Begin profile
# ------------------------------------------------------------------------------
# Initial version from Beyond Linux From Scratch by
#	* James Robertson <jameswrobertson@earthlink.net>
#	* Dagmar d'Surreal <rivyqntzne@pbzpnfg.arg>
# ------------------------------------------------------------------------------
# Current version from Geoffray Levasseur <fatalerrors@geoffray-levasseur.org>
# 16/02/2013 v1.0.0 : Initial version
# 24/10/2015 v2.0.0 : Added advanced functionnalities (clean, srr, etc.)
# 04/02/2017 v2.0.1 : clean improvements (--shell)
# 16/09/2018 v2.1.0 : Added rmhost, setc, setfr, more locales management
# 23/09/2019 v2.1.1 : [bugfix] dpkgs
# 24/09/2019 v2.1.2 : [bugfix] bug in profile version display
# 16/12/2019 v2.2.0 : Added showinfo, primary write of showdiskmap
# 08/01/2020 v2.3.0 : Added use of figlet and neofetch as a motd replace
# 16/01/2020 v2.3.1 : [bugfix] non-interactive were blocked with some functions
# 31/01/2020 v2.3.2 : Figlet: changed default font to ansi_shadow
# 02/03/2020 v2.4.0 : Added command auzip
# 03/03/2020 v2.5.0 : Added command taz and rmspc, auzip => utaz improved
# 05/03/2020 v2.5.1 : Language consistancy fix, added pigz support in taz
# 06/03/2020 v2.5.2 : Few aliases sorted out
# 11/09/2020 v2.5.3 : Few more aliases, improved code consistancy and typo,
#                   : improved utaz, removed showdiskmap, removed remaining French,
#                   : added license information for future publication
# 24/10/2020 v2.6.0 : Added session save and restore for Konsole
# 25/12/2020 v2.6.1 : Add check on rmhost, improvements rmspc, created expendlist
# 26/02/2021 v2.6.2 : [bugfix] taz: corrected bug with trailing slash on directories
# 18/10/2021 v2.6.3 : changed PS1 for status bar style version, few minor improvements
# 21/06/2022 v2.7.0 : added isipv4 and isipv6, use it in rmhost as an improvement
# 22/06/2022 v2.7.1 : [bugfix] few minor corrections, added help command
# 24/06/2022 v2.8.0 : Added backtrace, error and settrace, corrected showinfo
# 19/07/2022 v2.8.1 : few cleanup, fixes and optimizations
# 29/07/2022 v2.8.2 : added warning for non bash users
# 27/08/2022 v3.0.0 : splitted everything, added rain screensaver
# 07/11/2022 v3.0.1 : added concatenation to rmspc, added ku, error managed in meteo
# 08/11/2022 v3.1.0 : added password generator
# 10/11/2022 v3.1.1 : genpwd: test if password is doable
# 18/11/2022 v3.2.0 : created disp command for display, make use of it
# ------------------------------------------------------------------------------
# Copyright (c) 2013-2022 Geoffray Levasseur <fatalerrors@geoffray-levasseur.org>
# Protected by the BSD3 license. Please read bellow for details.
#
# * Redistribution and use in source and binary forms,
# * with or without modification, are permitted provided
# * that the following conditions are met:
# *
# *   Redistributions of source code must retain the above
# *   copyright notice, this list of conditions and the
# *   following disclaimer.
# *
# *   Redistributions in binary form must reproduce the above
# *   copyright notice, this list of conditions and the following
# *   disclaimer in the documentation and/or other materials
# *   provided with the distribution.
# *
# *   Neither the name of the copyright holder nor the names
# *   of any other contributors may be used to endorse or
# *   promote products derived from this software without
# *   specific prior written permission.
# *
# * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# * OF SUCH DAMAGE.
# ------------------------------------------------------------------------------

export PROFVERSION="3.1.1"

export DEFAULT_CITY="Toulouse"

if [[ ! $(echo $SHELL | grep bash) ]]; then
    echo "That environmet script is designed to be used with bash or zsh being the shell."
    echo "Please consider using bash or zsh instead, or patch me ;)!"
    return 1
fi

# ------------------------------------------------------------------------------
# path* : private functions for PATH variable management
# ------------------------------------------------------------------------------
pathremove ()
{
    local ifs=':'
    local newpath
    local dir
    local pathvar=${2:-PATH}
    for dir in ${!pathvar} ; do
        if [ "$dir" != "$1" ] ; then
            newpath=${newpath:+$newpath:}$dir
        fi
    done
    export $pathvar="$newpath"
}

pathprepend ()
{
    pathremove $1 $2
    local pathvar=${2:-PATH}
    export $pathvar="$1${!pathvar:+:${!pathvar}}"
}

pathappend ()
{
    pathremove $1 $2
    local pathvar=${2:-PATH}
    export $pathvar="${!pathvar:+${!pathvar}:}$1"
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ********************************** MAIN PROGRAM ******************************
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# Build PATH environment variable
if [[ $EUID -eq 0 ]] ; then
    pathappend /sbin:/usr/sbin
fi
[[ -d /share/services/gestparc ]] && pathappend /share/services/gestparc
[[ -d ~/bin ]] && pathappend ~/bin
[[ -d ~/.local/bin ]] && pathappend ~/.local/bin

# Set bash history
export HISTSIZE=50000
export HISTIGNORE="&:[bf]g:exit"

# Set default pager
export PAGER=less

# More colors
export TERM=xterm-256color

# Set some compiling values
export CFLAGS="-O2 -pipe -march=native"
export MAKEFLAGS='-j12'
export PKGSOURCES='/share/src/archives'


# ------------------------------------------------------------------------------
# Default values could be altered after this line
# ------------------------------------------------------------------------------

# Load personal configuration
[[ -f ~/.profile.conf ]] && . ~/.profile.conf

# Execute optionnal config script if any
for script in ~/profile.d/*.sh ; do
    if [ -r $script ] ; then
        . $script
    fi
done

# Interactive shell detection, two methods available each one of those might have different result
# depending on distribution
#shopt -q login_shell && INTERACTIVE=1
[[ $- == *i* ]] && INTERACTIVE=1

if [[ $INTERACTIVE ]]; then
    # For compiling (as we often compile with LFS/0linux...)
    #Aliases
    alias ll='ls -laFh --color=auto'
    alias la='ls -Ah --color=auto'
    alias l='ls -CF --color=auto'
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias qfind="find . -name "

    alias mkck='make check'
    alias mkin='make install'
    alias mkdin='make DESTDIR=$PWD/dest-install install'
    alias ssh='ssh -Y'

    alias wget='wget -c' # resume mode by default
    alias myip='curl ip.appspot.com'

    # Human readable by default
    alias df='df -H'
    alias du='du -ch'

    alias sdu='du -sk ./* | sort -n'

    # Define PS1
    trap 'timer_start' DEBUG
    PROMPT_COMMAND='set_prompt'

    # Set default language
    setfr
    showinfo
    disp I "Profile version $PROFVERSION chargé..."
fi

# Cleanup
unset pathremove pathprepend pathappend

#return 0

# End profile.sh
