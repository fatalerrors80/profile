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
# Display a backtrace
# ------------------------------------------------------------------------------
function backtrace ()
{
    echo "========= Call stack ========="
    typeset -i i=0
    
    local func=
    for func in "${FUNCNAME[@]}"; do
        if [[ $i -ne 0 ]]; then
            printf '%15s() %s:%d\n' \
                   "$func" "${BASH_SOURCE[$i]}" "${BASH_LINENO[ (( $i - 1)) ]}"
        fi
        let i++ || true
    done
    unset func i
    echo "=============================="
}

# ------------------------------------------------------------------------------
# Function to be trapped for errors investigation
# ------------------------------------------------------------------------------
function error ()
{
    local errcode=$?
    backtrace
    return $errcode
}


# ------------------------------------------------------------------------------
# Activate or deactivate error trapping to display backtrace
# ------------------------------------------------------------------------------
settrace ()
{
    local status="off"
    [[ $(trap -p ERR) ]] && status="on"
    #trap -p ERR
    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
		echo "Try to activate backtrace display for script debugging."
		echo
		echo "Options:"
		echo "	--on	Activate backtrace generation"
		echo "	--off	Deactivate backtrace generation"
		echo
		echo "That function active a trap event on error. If the script you want to"
		echo "debug overload the ERR bash trap, it will not work."
		echo
		;;
	    "--on")
		if [[ $status == "on" ]]; then
		    disp W "ERR signal trap is already set, replacing previous trap!"
		fi
		trap "error" ERR
		;;
	    "--off")
		if [[ $status != "on" ]]; then
		    disp W "ERR signal trap is already unset!"
		fi
		trap - ERR
		;;
	    "--status")
		disp "ERR trap signal is ${status}."
		;;
	esac
    done
    unset status
}
export -f settrace
