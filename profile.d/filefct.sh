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
                disp E "Invalid option, use \"clean --help\" to display usage."
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
# Create a directory then goes inside
# ------------------------------------------------------------------------------
mcd ()
{
    if [[ ! $# -eq 1 ]] ; then
        disp E "Create a directory then goes inside."
        disp E "Usage: mcd <directory>"
        return 1
    fi
    mkdir -pv $1 && cd $1
}
export -f mcd


# ------------------------------------------------------------------------------
# Rename all files in current directory to replace spaces with _
# ------------------------------------------------------------------------------
rmspc ()
{
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
                echo "	-v, --verbose		Display more details (recursive mode only)"
                echo "	-s, --shell		Do nothing and display commands that would be executed"
		echo
		echo "Note: if the --subst-char option is given without parameters, spaces will be"
		echo "      replaced with nothing (concatenation)."
		echo
		return 0
                ;;

            "-r"|"--recursive")
                local recurs=1
                ;;

            "-c"?*|"--subst-char"?*)
		if [[ $(echo $opt | grep "=") ]]; then
                    local substchar=$(echo "$opt" | cut -f 2- -d '=')
		else
		    local substchar='none'
		fi
		;;

	    "-v"|"--verbose")
		local verb=1
                ;;

            "-s"|"--shell")
                local shell=1
                ;;

            *)
                disp E "Invalid parameter, use \"rmspc --help\" to display options list"
                echo
                return 1
                ;;
        esac
    done

    [[ ! $substchar ]] && substchar="_"
    [[ $substchar == "none" ]] && local substchar=""
    [[ $verb ]] && local mvopt="-v"

    for f in *; do
        [[ $recurs ]] && [[ -d "$f" ]] && (
            [[ $verb ]] && disp I "Entering directory $(pwd)/$f ..."
	    local lastdir=$f
            pushd "$f" > /dev/null
            rmspc $@
            popd > /dev/null
            [[ $verb ]] && disp I "Leaving directory $(pwd)/$lastdir"
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
