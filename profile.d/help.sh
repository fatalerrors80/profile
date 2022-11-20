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
# Display list of commands and general informations
# ------------------------------------------------------------------------------
help()
{
    cat <<EOF
clean		Erase backup files
dpkgs		Search for the given package in the installed ones 
gpid		Give the list of PIDs for the given process name
isipv4		Tell if the given IPv4 is valid
isipv6		Tell if the given IPv6 is valid
ku		Kill process owned by users in parameter
mcd		Create a directory and go inside
meteo		Display curent weather forecast for the configured city
ppg		Display process matching the given parameter
rain		Let the rain fall
rmhost		Remove host (IP and/or DNS name) for current known_host
rmspc		Remove spaces from all the files in working directory
setc		Set console language to C
setfr		Set console language to French
settrace	Activate/deactivate call trace for script debugging
setus		Set console language to US English
showinfo	Show the welcoming baner with basic system information
ssr		Do a root login to the given address
taz		Compress smartly the given files or directory
utaz		Uncompress all zip files in the given (or current) directory
ver		Display version of your copy of profile

Please use <command> --help to obtain usage details.
EOF
}
export -f help

