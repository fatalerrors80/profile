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
# Remove host from know_host (name and IP) for the active user
# ------------------------------------------------------------------------------
rmhost ()
{
    if [[ "$#" -lt 1 ]]; then
        disp E "Incorrect number of parameters."
        disp E "Usage: rmhost <hostname|ip> [hostname2|ip2 [...]]"
        return 1
    fi
    
    while [[ $1 ]]; do
	local hst=$1 && shift
	isipv4 $hst > /dev/null
	local v4=$?
	isipv6 $hst > /dev/null
	local v6=$?
	
	if [[ $v4 -eq 0 || $v6 -eq 0 ]]; then
	    local ip=$hst
	    unset hst
	fi
	unset v4 v6
	
	if [[ ! $ip && $hst ]]; then
	    ip=$(host $hst | grep "has address" | awk '{print $NF}')
	    [[ ! $? ]] &&
		disp E "Impossible to extract IP from hostname." &&
		return 1
	fi
	
	if [[ $hst ]]; then
	    disp I "Removing host $hst from ssh known_host..."
	    ssh-keygen -R $hst > /dev/null
	fi
	if [[ $ip ]]; then
	    disp I "Removing IP $ip from ssh known_host..."
	    ssh-keygen -R $ip > /dev/null
	fi
	unset hst ip
    done
}
export -f rmhost


# ------------------------------------------------------------------------------
# Login root via SSH on the given machine
# ------------------------------------------------------------------------------
ssr ()
{
    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
                echo "ssr: do a root user ssh login."
                echo
                echo "Usage: ssr <server [ssh options]>"
                return 0
                ;;
        esac
    done

    [[ ! $1 ]] &&
        disp E "Please specify the server you want to log in." &&
        return 1

    local srv=$1 && shift

    ssh -Y root@$srv $@
}
export -f ssr
