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

# ------------------------------------------------------------------------------
# timer_* functions : internal timing function for prompt
# ------------------------------------------------------------------------------
function timer_now
{
    date +%s%N
}

function timer_start
{
    timer_start=${timer_start:-$(timer_now)}
}

function timer_stop
{
    local delta_us=$((($(timer_now) - $timer_start) / 1000))
    local us=$((delta_us % 1000))
    local ms=$(((delta_us / 1000) % 1000))
    local s=$(((delta_us / 1000000) % 60))
    local m=$(((delta_us / 60000000) % 60))
    local h=$((delta_us / 3600000000))
    # Goal: always show around 3 digits of accuracy
    if ((h > 0)); then
        timer_show=${h}h${m}m
    elif ((m > 0)); then
        timer_show=${m}m${s}s
    elif ((s >= 10)); then
        timer_show=${s}.$((ms / 100))s
    elif ((s > 0)); then
        timer_show=${s}.$(printf %03d $ms)s
    elif ((ms >= 100)); then
        timer_show=${ms}ms
    elif ((ms > 0)); then
        timer_show=${ms}.$((us / 100))ms
    else
        timer_show=${us}us
    fi
    unset timer_start
}

# ------------------------------------------------------------------------------
# Function triguered internaly by bash : defining prompt
# ------------------------------------------------------------------------------
set_prompt ()
{
    Last_Command=$? # Must come first!
    Blue='\[\e[0;34m\]'
    White='\[\e[01;37m\]'
    Yellow='\[\e[01;93m\]'
    Red='\[\e[01;31m\]'
    Green='\[\e[01;32m\]'
    OnGrey='\[\e[47m\]'
    OnRed='\[\e[41m\]'
    OnBlue='\[\e[44m\]'
    ICyan='\[\e[0;96m\]'
    Default='\[\e[00m\]'
    FancyX='\342\234\227'
    Checkmark='\342\234\223'

    # Begin with time
    PS1="\[\e[s$Blue$OnGrey [ \t ] $OnBlue"

    # Add a bright white exit status for the last command

    # If it was successful, print a green check mark. Otherwise, print
    # a red X.
    if [[ $Last_Command == 0 ]]; then
        PS1+="$White$OnBlue [ \$Last_Command "
        PS1+="$Green$Checkmark "
    else
        PS1+="$White$OnRed [ \$Last_Command "
        PS1+="$Yellow$FancyX "
    fi

    # Add the ellapsed time and current date
    timer_stop
    PS1+="($timer_show)$White ] $OnBlue "

    # If root, just print the host in red. Otherwise, print the current user
    # and host in green.
    if [[ $EUID -eq 0 ]]; then
        PS1+="$Red\\u$Green@\\h"
    else
        PS1+="$Green\\u@\\h"
    fi
    PS1+="\e[K\e[u$Default\n"
    # Print the working directory and prompt marker in blue, and reset
    # the text color to the default.
    PS1+="$ICyan\\w \\\$$Default "
}
