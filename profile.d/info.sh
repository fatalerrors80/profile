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
# Show profile version
# ------------------------------------------------------------------------------
ver ()
{
    disp "Profile version $PROFVERSION."
}
export -f ver


# ------------------------------------------------------------------------------
# Display weather of the given city (or default one)
# ------------------------------------------------------------------------------
meteo ()
{
    cities=$@
    [[ $# -eq 0 ]] && local cities=$DEFAULT_CITY

    for city in $cities; do
        curl https://wttr.in/$city || disp E "Failed fetching datas for $city."
    done
}
export -f meteo


# ------------------------------------------------------------------------------
# Display system general information
# ------------------------------------------------------------------------------
showinfo()
{
    echo -e "\n"
    if command -v figlet >/dev/null 2>&1; then 
	if [[ -s /usr/share/figlet/ansi_shadow.flf ]]; then
	    local figopt="-f ansi_shadow"
	fi
	figlet -k $(hostname) $figopt
    else
	echo "$(hostname -f)"
    fi
    echo ""
    if command -v neofetch >/dev/null 2>&1; then
	neofetch
    else
	(
	    if [[ -s /etc/os-release ]]; then
		. /etc/os-release
		echo "$NAME $VERSION"
	    else
		cat /proc/version
	    fi
	    echo "Uptime: $(uptime)"
	)
    fi
}
export -f showinfo
