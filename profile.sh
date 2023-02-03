#!/bin/bash
# Begin profile
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

# Store script's path (realpath -s resolve symlinks if profile.sh is a symlink)
export MYPATH=$(dirname $(realpath -s $0))

if [[ ! -s $MYPATH/version ]]; then
    echo "Impossible to determine running version of profile, your installation might be broken."
fi
export PROFVERSION=$(cat $MYPATH/version)

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

# Default city for weather forcast
export DEFAULT_CITY="Toulouse"

# ------------------------------------------------------------------------------
# Default values could be altered after this line
# ------------------------------------------------------------------------------

# Load global configuration
[[ -f $MYPATH/etc/profile.conf ]] && . ~/.profile.conf

# Load personal configuration
[[ -f ~/.profile.conf ]] && . ~/.profile.conf

# Load module scripts
for script in $MYPATH/profile.d/*.sh ; do
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
