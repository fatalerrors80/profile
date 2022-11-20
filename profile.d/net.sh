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
# Determine if parameter is a valid IPv4 address
# ------------------------------------------------------------------------------
isipv4 ()
{
    # Set up local variables
    local  ip=$1

    # Start with a regex format test
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	local old_ifs=$IFS
	IFS="."
	ip=($ip)
	IFS=$old_ifs
	if [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
		  && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]; then
	    if [[ -t 1 ]]; then
		disp "The given IPv4 is valid."
	    fi
	    return 0
	fi
    fi
    if [[ -t 1 ]]; then
	disp "The given parameter is NOT a valid IPv4."
    fi
    return 1
}
export -f isipv4


# ------------------------------------------------------------------------------
# Determine if parameter is a valid IPv4 address
# ------------------------------------------------------------------------------
isipv6 ()
{
    local ip="$1"
    local regex='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'
    if [[ $ip =~ $regex ]]; then
	if [[ -t 1 ]]; then
	    disp "The given IPv6 is valid."
	fi
	return 0
    fi
    if [[ -t 1 ]]; then
	disp "The given parameter is not a valid IPv6."
    fi
    return 1
}
export -f isipv6
