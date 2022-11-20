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
# Search processes matching the given string
# ------------------------------------------------------------------------------
ppg ()
{
    ps -edf | grep $@ | grep -v "grep $@"
}
export -f ppg


# ------------------------------------------------------------------------------
# Get PID list of the given process name
# ------------------------------------------------------------------------------
gpid ()
{
    [[ $UID -eq 0 ]] && local psopt="-A"
    [[ $# -eq 1 ]] && local single=1
    for pid in $@; do
        local result=$(ps $psopt | grep $pid | awk '{print $1}' | sed "s/\n/ /")
        if [[ $single ]]; then
            [[ $result ]] && echo "${result//$'\n'/ }"
        else
            [[ $result ]] && echo "$pid: ${result//$'\n'/ }"
        fi
    done
    [[ $result ]] || return 1
}
export -f gpid


# ------------------------------------------------------------------------------
# Kill all processes owned by the given users
# ------------------------------------------------------------------------------
ku ()
{
    for u in $@; do
        killall -u $u
    done
}
export -f ku
