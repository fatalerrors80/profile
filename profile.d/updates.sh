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

export UPDT_URL="https://git.geoffray-levasseur.org/fatalerrors/profile/raw/branch/master"

# ------------------------------------------------------------------------------
# Check for profile updates
# ------------------------------------------------------------------------------
check_updates()
{
    if [[ $1 == "-q" ]]; then
	# Quiet mode is mostly used internally when profile_upgrade is called
	quiet=1
    fi
    disp I "Checking for updates..."
    local vfile="/tmp/version"
    wget "$UPDT_URL/version" -O $vfile >/dev/null 2>&1 || {
	disp E "Can't download version file, impossible to proceed!"
	return 5
    }
    if [[ -s /tmp/version ]]; then
	local lastver=$(cat /tmp/version)
	if [[ $lastver != $PROFVERSION ]]; then
	    disp I "You have version $PROFVERSION installed. Version $lastver is available."
	    [[ $quiet ]] && disp I "You should upgrade to last version when possible."
	    result=0
	else
	    disp I "Your version is up-to-date."
	    result=1
	fi
	rm -f $vfile
    else
	disp E "Impossible to read temporary file, impossible to proceed."
    fi
    unset lastver vfile
    return $result
}

# ------------------------------------------------------------------------------
# Apply update to profile
# ------------------------------------------------------------------------------
profile_upgrade()
{
    if [[ $(check_updates -q) -eq 0 ]]; then
	if [[ -s $MYPATH/profile.sh ]]; then
	    disp E "Installation path detection failed, cannot upgrade automatically."
	    return 1
	fi
	if [[ -d $MYPATH/.git ]]; then
	    disp I "Git installation detected, applying git pull."
	    local curdir=$(pwd)
	    cd $MYPATH
	    git pull
	    if [[ $? -ne 0 ]]; then
		disp E "Git pull failed, upgrade not applyed."
	    else
		disp I "Successfully upgraded using git."
		disp I "You should now logout and login again to enjoy new profile."
		cd $curdir
	    fi
	else
	    disp I "Applying traditionnal upgrade..."
	    # TODO
	fi
    fi
}

# EOF
