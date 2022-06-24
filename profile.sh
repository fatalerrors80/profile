#!/bin/bash
# Begin profile
# ------------------------------------------------------------------------------
# Initial version from Beyond Linux From Scratch by
#	* James Robertson <jameswrobertson@earthlink.net>
#	* Dagmar d'Surreal <rivyqntzne@pbzpnfg.arg>
# ------------------------------------------------------------------------------
# Current version from Geoffray Levasseur <fatalerrors@geoffray-levasseur.org>
# 16/02/2013 v1.0.0 : Initial version
# 24/10/2015 v2.0.0 : Added advanced functionnalities (clean, srr, etc.)
# 04/02/2017 v2.0.1 : clean improvements (--shell)
# 16/09/2018 v2.1.0 : Added rmhost, setc, setfr, more locales management
# 23/09/2019 v2.1.1 : [bugfix] dpkgs
# 24/09/2019 v2.1.2 : [bugfix] bug in profile version display
# 16/12/2019 v2.2.0 : Added showinfo, primary write of showdiskmap
# 08/01/2020 v2.3.0 : Added use of figlet and neofetch as a motd replace
# 16/01/2020 v2.3.1 : [bugfix] non-interactive were blocked with some functions
# 31/01/2020 v2.3.2 : Figlet: changed default font to ansi_shadow
# 02/03/2020 v2.4.0 : Added command auzip
# 03/03/2020 v2.5.0 : Added command taz and rmspc, auzip => utaz improved
# 05/03/2020 v2.5.1 : Language consistancy fix, added pigz support in taz
# 06/03/2020 v2.5.2 : Few aliases sorted out
# 11/09/2020 v2.5.3 : Few more aliases, improved code consistancy and typo,
#                   : improved utaz, removed showdiskmap, removed remaining French,
#                   : added license information for future publication
# 24/10/2020 v2.6.0 : Added session save and restore for Konsole
# 25/12/2020 v2.6.1 : Add check on rmhost, improvements rmspc, created expendlist
# 26/02/2021 v2.6.2 : [bugfix] taz: corrected bug with trailing slash on directories
# 18/10/2021 v2.6.3 : changed PS1 for status bar style version, few minor improvements
# 21/06/2022 v2.7.0 : added isipv4 and isipv6, use it in rmhost as an improvement
# 22/06/2022 v2.7.1 : [bugfix] few minor corrections, added help command
# 24/06/2022 v2.8.0 : Added backtrace, error and settrace, corrected showinfo
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

export PROFVERSION="2.8.0"

export DEFAULT_CITY="Toulouse"

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
# expandlist : treat wildcards in a file/directory list
# ------------------------------------------------------------------------------
expandlist()
{
    local result=""
    for item in "$1"; do
        for content in "$item"; do
            result+="\"$content\" "
        done
    done
    echo $result
}

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

# ------------------------------------------------------------------------------
# Show profile version
# ------------------------------------------------------------------------------
ver ()
{
    echo "Profile version $PROFVERSION."
}
export -f ver

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
		echo "The given IPv4 is valid."
	    fi
	    return 0
	else
	    if [[ -t 1 ]]; then
		echo "The given parameter is NOT a valid IPv4."
	    fi
	    return 1
	fi
    else
	if [[ -t 1 ]]; then
	    echo "The given parameter is NOT a valid IPv4."
	fi
	return 1
    fi
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
	    echo "The given IPv6 is valid."
	fi
	return 0
    else
	if [[ -t 1 ]]; then
	    echo "The given parameter is not a valid IPv6."
	fi
	return 1
    fi
}
export -f isipv6


# ------------------------------------------------------------------------------
# Change locale to French
# ------------------------------------------------------------------------------
setfr ()
{
    # Set fr locale definitions
    export LANG=fr_FR.UTF-8
    export LC_MESSAGES=fr_FR.UTF-8
    export LC_ALL=fr_FR.UTF-8
}
export -f setfr

# ------------------------------------------------------------------------------
# Change locale to C standard
# ------------------------------------------------------------------------------
setc ()
{
    # Locale definitions
    export LANG=C
    export LC_MESSAGES=C
    export LC_ALL=C
}
export -f setc

# ------------------------------------------------------------------------------
# Change locale to US (needed by Steam)
# ------------------------------------------------------------------------------
setus ()
{
    # Locale definitions
    export LANG=en_US.UTF-8
    export LC_MESSAGES=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
}
export -f setus

# ------------------------------------------------------------------------------
# Display weather of the given city (or default one)
# ------------------------------------------------------------------------------
meteo ()
{
    cities=$@
    [[ $# -eq 0 ]] && local cities=$DEFAULT_CITY

    for city in $cities; do
        curl https://wttr.in/$city
    done
}
export -f meteo

# ------------------------------------------------------------------------------
# Clean a directory or a tree from temporary or backup files
# ------------------------------------------------------------------------------
clean ()
{
    for opt in $@ ; do
        case $opt in
            "-r"|"--recurs")
                local recursive=1
                ;;

            "-h"|"--help")
                echo "clean: erase backup files in the given directories."
                echo
                echo "Usage: clean [option] [directory1] [...[directoryX]]"
                echo
                echo "Options:"
                echo "	-h, --help	Display that help screen"
                echo "	-r, --recurs	Do a recursive cleaning"
                echo "	-f, --force	Do not ask for confirmation (use with care)"
                echo "	-s, --shell	Do nothing and display what will be executed"
                echo
                return 0
                ;;

            "-s"|"--shell")
                local outshell=1
                ;;

            "-f"|"--force")
                local force=1
                ;;

            "-"*)
                echo "Invalid option, use \"clean --help\" to display usage."
                echo
                return 1
                ;;

            *)
                local dirlist="$dirlist $opt"
                ;;
        esac
    done

    [[ ! $dirlist ]] && local dirlist=$(pwd)

    [[ ! $recursive ]] && local findopt="-maxdepth 1"
    [[ ! $force ]] && local rmopt="-i"
    unset recursive force

    for dir in $dirlist; do
        local dellist=$(find $dir $findopt -type f -name "*~" -o -name "#*#" \
            -o -name "*.bak" -o -name ".~*#")
        for f in $dellist; do
            if [[ ! $outshell ]]; then
                rm $rmopt $f
            else
                echo "rm $rmopt $f"
            fi
        done
    done
    unset outshell dirlist dellist findopt rmopt
}
export -f clean

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
        echo "Please specify the server you want to log in." &&
        return 1

    local srv=$1 && shift

    ssh -Y root@$srv $@
}
export -f ssr

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
                echo "Invalid option, use \"dpkgs --help\" to display usage."
                echo
                return 1
                ;;

            *)
                local pkg=$1 && shift
                count=$(( $count + 1 ))
                [[ $count -gt 1 ]] &&
                    echo "*** Error: Please specify a package name, without space, eventually partial." &&
                    return 1

                ;;
        esac
    done
    [[ $count -lt 1 ]] &&
        echo "*** Error: Please specify a package name, without space, eventually partial." &&
        return 1

    [[ -x /usr/sbin/dpkg ]] &&
        echo "*** Error: dpkg command seems unavialable." &&
        return 2

    dpkg -l | grep $pkg
}
export -f dpkgs

# ------------------------------------------------------------------------------
# Search processes matching the given string
# ------------------------------------------------------------------------------
ppg ()
{
    ps -edf | grep $@ | grep -v "grep $@"
}
export -f ppg

# ------------------------------------------------------------------------------
# Create a directory then goes inside
# ------------------------------------------------------------------------------
mcd () {
    if [[ ! $# -eq 1 ]] ; then
        echo "Create a directory then goes inside."
        echo "Usage: mcd <directory>"
        return 1
    fi
    mkdir -pv $1 && cd $1
}
export -f mcd

# ------------------------------------------------------------------------------
# Get PID list of the given process name
# ------------------------------------------------------------------------------
gpid () {
    [[ $# -eq 1 ]] && local single=1
    for pid in $@; do
        local result=$(ps -A | grep $pid | awk '{print $1}')
        if [[ $single ]]; then
            [[ $result ]] && echo "$result"
        else
            [[ $result ]] && echo "$pid: $result"
        fi
    done
    [[ $result ]] || return 1
}
export -f gpid


# ------------------------------------------------------------------------------
# Remove host from know_host (name and IP) for the active user
# ------------------------------------------------------------------------------
rmhost () {
    if [[ "$#" -lt 1 ]]; then
        echo "Error: incorrect number of parameters."
        echo "Usage: rmhost <hostname|ip> [hostname2|ip2 [...]]"
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
		echo "*** rmhost(): Error extracting IP from hostname." &&
		return 1
	fi
	
	if [[ $hst ]]; then
	    echo "Removing host $hst from ssh known_host..."
	    ssh-keygen -R $hst > /dev/null
	fi
	if [[ $ip ]]; then
	    echo "Removing IP $ip from ssh known_host..."
	    ssh-keygen -R $ip > /dev/null
	fi
	unset hst ip
    done
}
export -f rmhost


# ------------------------------------------------------------------------------
# Rename all files in current directory to replace spaces with _
# ------------------------------------------------------------------------------
rmspc () {
    local lst=""
    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
                echo "rmspc: remove spaces from all filenames in current directories"
                echo
                echo "Usage: rmspc [option]"
                echo
                echo "Options:"
                echo "	-h, --help		Display that help screen"
                echo "	-r, --recursive		Treat subdirectories of the given directory"
                echo "	-c, --subst-char	Change the replacement character (default is underscore)"
                echo "	-v, --verbose		Display what is being done"
                echo "	-s, --shell		Do nothing and display commands that would be executed"
                echo
                return 0
                ;;

            "-r"|"--recursive")
                local recurs=1
                ;;

            "-c"?*|"--subst-char"?*)
                local substchar=$(echo "$opt" | cut -f 2- -d '=')
                ;;

            "-v"|"--verbose")
                local verb=1
                ;;

            "-s"|"--shell")
                local shell=1
                ;;

            *)
                echo "Invalid parameter, use \"rmspc --help\" to display options list"
                echo
                return 1
                ;;
        esac
    done

    [[ ! $substchar ]] && substchar="_"
    [[ $verb ]] && local mvopt="-v"

    for f in *; do
        [[ $recurs ]] && [[ -d "$f" ]] && (
            [[ $verb ]] && echo "-- Entering directory $(pwd)/$f ..."
	    local lastdir=$f
            pushd "$f" > /dev/null
            rmspc $@
            popd > /dev/null
            [[ $verb ]] && echo "-- Leaving directory $(pwd)/$lastdir"
	    unset lastdir
        )

        if [[ $(echo $f | grep " ") ]]; then
            local newf="${f// /${substchar}}"
            local command="mv $mvopt \"$f\" \"$newf\""
            if [[ $shell ]]; then
                echo $command
            else
                $command
            fi
        fi
    done
    unset lst substchar verb shell newf command mvopt 
}
export -f rmspc

# ------------------------------------------------------------------------------
# Smartly uncompress archives (zip only)
# ------------------------------------------------------------------------------
utaz()
{
    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
                echo "utaz: uncompress all the given files and/or the ones found in the given"
                echo "      directories creating an host directory where needed."
                echo
                echo "Usage: utaz [option] [directorie(s)|file(s)]"
                echo
                echo "Options:"
                echo "	-h, --help		Display that help screen"
                echo "	-d, --delete		If decompression succeeded, delete the source file"
                echo "	-c, --create-dir	Always create a host directory"
                echo "	-n, --no-dir		Never create a host directory"
                echo
                return 0
                ;;

            "-d"|"--delete")
                local willrm=1
                ;;

            "-c"|"--create-dir")
                local createdir=1
                ;;

            "-n"|"--no-dir")
                local nodir=1
                ;;

            "-"*)
                echo "Invalid option, use \"utaz --help\" to display options list"
                echo
                return 1
                ;;

            *)
                # The ${opt%/} writing is to remove trailing / if any
                local LIST="$LIST ${opt%/}"
                ;;
        esac
    done

    [[ $createdir && $nodir ]] && echo "*** Error: --create-dir and --no-dir options are mutually exclusive."

    [[ ! $LIST ]] && local LIST="."

    for zitem in $LIST; do
        [[ $(ls $zitem/*.zip 2> /dev/null | wc -l) -eq 0 ]] &&
            echo "$zitem contains no supported archive file, skipping." &&
            continue

        for f in $zitem/*.zip; do
            echo -n "Processing archive $zitem/$f... "
            local dir=${f::-4}

            mkdir -p $dir
            [[ $? -gt 0 ]] &&
                echo "[ filesystem can't create directories, exit ]" &&
                return 1

            unzip -o $f -d $dir > /dev/null 2>&1
            case $? in
                0)
                    [[ $willrm ]] && rm -f $f && echo -n "Deleted ! "
                    ;;

                1)
                    echo "No deletion on warnings "
                    ;;
                *)
                    echo "[ zip file corrupted, failed ]"
                    rm -rf $dir > /dev/null 2>&1
                    continue
                    ;;
            esac

            if [[ $createdir ]]; then
                echo -n "[ subdir created, "
            elif [[ $nodir ]]; then
                mv ./$dir/* ./ && rmdir $dir
                echo -n "[ No subdir, "
            else
                subdirs=$(find $dir -maxdepth 1 | wc -l)
                if [[ $subdirs -eq 2 ]]; then
                    mv ./$dir/* ./ && rmdir $dir
                    echo -n "[ No subdir, "
                else
                    echo -n "[ subdir created, "
                fi
            fi
            echo " OK ]"
        done
    done
}
export -f utaz

# ------------------------------------------------------------------------------
# Compress directories or files into one or more archive
# ------------------------------------------------------------------------------
taz ()
{
    _doxz()
    {
        command -v xz >/dev/null 2>&1 || {
            echo -e >&2 "\t*** The program 'xz' is not installed, aborting."
            return 127
        }

        [[ $4 ]] && local verb='-v'

        # Display a warning for this format
        echo -e "\t! Warning: xz format is not suited for long term archiving."
        echo -e "\t	      See https://www.nongnu.org/lzip/xz_inadequate.html for details."

        # Compresse to xz (lzma2) - Deprecated 
        xz $verb --compress --keep -$3 -T $2 $1
        return $?
    }

    _dolz()
    {
        local procopt="--threads $2"
        local command=plzip

        command -v plzip >/dev/null 2>&1 || {
            command -v lzip >/dev/null 2>&1 || {
                echo -e >&2 "\t*** Program 'plzip' or 'lzip' are not installed, aborting."
                return 127
            }
            local command=lzip
            local procopt=""
            [[ $2 -gt 1 ]] &&
                echo -e "\t! Warning: lzip doesn't support multithreading, falling back to 1 thread." &&
                echo -e "\t* Consitder installing plzip to obtain multithreading abilities."
        }

        [[ $4 ]] && local verb="-vv"

        # Compresse au format lzip (lzma)
        $command $verb $procopt --keep -$3 $1
        return $?
    }

    _dogz()
    {
        local procopt="--processes $2"
        local command=pigz

        command -v pigz >/dev/null 2>&1 || {
            command -v gzip >/dev/null 2>&1 || {
                echo -e >&2 "\t*** Programs 'pigz' or 'gzip' are not installed, aborting."
                return 127
            }
            local command="gzip --compress"
            local procopt=""
            [[ $2 -gt 1 ]] &&
                echo -e "\t! Warning: gzip doesn't support multithreading, falling back to 1 thread." &&
                echo -e "\t* Consitder installing pigz to obtain multithreading abilities."
        }

        [[ $4 ]] && local verb="--verbose"

        # Compresse au format bz2
        $command $verb $procopt --keep -$3 $1
        return $?
    }

    _dobz2()
    {
        local procopt="-p$2"
        local command=pbzip2

        command -v pbzip2 >/dev/null 2>&1 || {
            command -v bzip2 >/dev/null 2>&1 || {
                echo -e >&2 "\t*** The program 'pbzip2' or 'bzip2' are not installed, aborting."
                return 127
            }
            local command=bzip2
            local procopt=""
            [[ $2 -gt 1 ]] &&
                echo -e "\t! Warning: bzip2 doesn't support multithreading, falling back to 1 thread." &&
                echo -e "\t* Consitder installing pbzip2 to obtain multithreading abilities."
        }

        [[ $4 ]] && local verb="-v"

        # Compresse au format bz2
        $command $verb --compress $procopt --keep -$3 $1
        return $?
    }

    _dolzo()
    {
        command -v lzop >/dev/null 2>&1 || {
            echo -e >&2 "\t*** The program 'lzop' is not installed, aborting."
            return 127
        }

        [[ $4 ]] && local verb='-v'
        [[ $2 -gt 1 ]] && echo -e "\t! Warning: lzop doesn't support multithreading, falling back to 1 thread."

        # Compresse au format lzo
        lzop --keep -$3 $1
        return $?
    }

    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
                echo "taz: archive all files of a directory."
                echo
                echo "Usage: taz [option] [--parallel=<n>] [--format=<format>] [directory1 ... directoryN]"
                echo
                echo "Options:"
                echo "	-h, --help	Display that help screen"
                echo "	-d, --delete	Delete source file or directory after success"
                echo "	-f, --format	Chose archive format in the given list. If several format are"
                echo "			given, the smalest is kept"
                echo "	-p, --parallel	Number of threads to use (if allowed by underlying utility)"
                echo "	-v, --verbose	Display progress where possible"
                echo "	-1, .., -9	Compression level to use [1=fast/big, 9=slow/small]"
                echo
                echo "Supported archive format:"
                echo "	Param.| programs      | Algo. | Description"
                echo "	------+---------------+-------+----------------------------------------"
                echo "	   lz | plzip, lzip   | lzma  | Safe efficient default format"
                echo "	   xz | xz            | lzma2 | Unsafe, not for long term"
                echo "	  bz2 | pbzip2, bzip2 | bzip2 | Historical but less efficient than lz"
                echo "	   gz | pigz, gzip    | lz77  | Historical, safe, fast"
                echo "	  lzo | lzop          | lzo   | Very fast but no multithread"
                echo "	  tar | tar           | tar   | No compression"
                echo
                return 0
                ;;

            "-d"|"--delete")
                local willrm=1
                ;;

            "-f"?*|"--format"?*)
                local compform=$(echo "$opt" | cut -f 2- -d '=')
                ;;

            "-p"?*|"--parallel"?*)
                local nproc=$(echo "$opt" | cut -f 2- -d '=')
                ;;

            "-v"|"--verbose")
                local verbose=1
                ;;

            "-"[1..9])
                local complevel=${opt:1:1}
                ;;

            "-"*)
                echo "Invalid option, use taz --help to display options list"
                echo
                return 1
                ;;

            *)
                local LIST="$LIST ${opt%/}"
                ;;
        esac
    done

    [[ ! $compform ]] && compform=lz # safe and efficient (unless data are already compressed)
    [[ ! $nproc ]] && nproc=1
    [[ ! $complevel ]] && complevel=6

    for item in $LIST; do
        local donetar=0
        echo "--- Processing $item..."

        if [[ -d $item ]]; then
            echo -ne "\t* Creating $item.tar... "

            tar -cf $item{.tar,}
            if [[ ! $? -eq 0 ]]; then
                echo "[ failed, skipping ]"
                continue
            fi

            local donetar=1
            echo "[ OK ]"
        fi

        local fname=$item
        [[ $donetar -gt 0 ]] && fname=$item.tar

        # Skip compression part if tar is asked
        if [[ $compform != "tar" ]]; then
            echo -e "\t* Compressing archive..."
            _do$compform $fname $nproc $complevel $verbose
            [[ ! $? -eq 0 ]] && case $? in
                127)
                    echo -e "\t*** Compression program unavailable, aborting."
                    return 127
                    ;;
                *)
                    echo -e "\t*** Compression program returned an error, not deleting anything if asked, skipping to next item."
                    continue
                    ;;
            esac

            [[ $donetar -gt 0 ]] && rm $fname
        fi

        if [[ $willrm ]]; then
            echo -en "\t* Deleting original source as asked... "
            rm -r $item && echo '[ OK ]' || echo '[ failed ]'
        fi

        echo "--- Done"
    done

}
export -f taz

# ------------------------------------------------------------------------------
# Display system general information
# ------------------------------------------------------------------------------
showinfo() {
    echo -e "\n"
    command -v figlet >/dev/null 2>&1 &&
	figlet -k $(hostname)
    echo ""
    command -v neofetch >/dev/null 2>&1 &&
	neofetch
}
export -f showinfo


# ------------------------------------------------------------------------------
# Display list of commands and general informations
# ------------------------------------------------------------------------------
help ()
{
    cat <<EOF
clean		Erase backup files
dpkgs		Search for the given package in the installed ones 
gpid		Give the list of PIDs for the given process name
isipv4		Tell if the given IPv4 is valid
isipv6		Tell if the given IPv6 is valid
mcd		Create a directory and go inside
meteo		Display curent weather forecast for the configured city
ppg		Display process matching the given parameter 
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

EOF
}


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
    exit $errcode
}


# ------------------------------------------------------------------------------
# Activate or deactivate error trapping to display backtrace
# ------------------------------------------------------------------------------
settrace ()
{
    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
		echo "Try to activate bactrace display for script debugging."
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
		trap "error" ERR
		;;
	    "--off")
		trap - ERR
		;;
	esac
    done
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ********************************** MAIN PROGRAM ******************************
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# Former PS1, stopped for much better function
# Set the prompt look'n'feel
# NORMAL="\[\e[0m\]"
# RED="\[\e[1;31m\]"
# GREEN="\[\e[1;32m\]"
# PURPLE="\[\e[1;35m\]"
# BLUEONGREY="\[\e[0;34m\e[47m\]"
# if [[ $EUID == 0 ]] ; then
#    export PS1="$BLUEONGREY[\t]$NORMAL $PURPLE\$?$NORMAL|$RED\u@\H:$NORMAL\w$RED\$ $NORMAL"
# else
#    export PS1="$BLUEONGREY[\t]$NORMAL $PURPLE\$?$NORMAL|$GREEN\u@\H:$NORMAL\w$GREEN\$ $NORMAL"
# fi

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


# ------------------------------------------------------------------------------
# Default values could be altered after this line
# ------------------------------------------------------------------------------

# Load personal configuration
[[ -f ~/.profile.conf ]] && . ~/.profile.conf

# Execute optionnal config script if any
for script in ~/profile.d/*.sh ; do
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
    echo "Profile version $PROFVERSION chargé..."
fi

# Cleanup
unset pathremove pathprepend pathappend

#return 0
# End /etc/profile
