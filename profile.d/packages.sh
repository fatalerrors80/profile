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
# Look for a package within installed one
# ------------------------------------------------------------------------------
dpkgs ()
{
    local count=0
    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
                echo "dpkgs: look for an installed package by it's name."
                echo
                echo "Usage: dpkgs <string>"
                return 0
                ;;

            "-"*)
                disp E "Invalid option, use \"dpkgs --help\" to display usage."
                echo
                return 1
                ;;

            *)
                local pkg=$1 && shift
                count=$(( $count + 1 ))
                [[ $count -gt 1 ]] &&
                    disp E "Please specify a package name, without space, eventually partial." &&
                    return 1

                ;;
        esac
    done
    [[ $count -lt 1 ]] &&
        disp E "Please specify a package name, without space, eventually partial." &&
        return 1

    if [[ $(command -v dpkg >/dev/null 2>&1) ]]; then
	dpkg -l | grep $pkg
    elif [[ $(command -v rpm >/dev/null 2>&1) ]]; then
	rpm -qa | grep $pkg
    else
	disp E "No usable package manager seems unavialable."
	return 2
    fi
}
export -f dpkgs
