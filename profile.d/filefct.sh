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
# Create a directory then goes inside
# ------------------------------------------------------------------------------
mcd ()
{
    if [[ ! $# -eq 1 ]] ; then
        echo "Create a directory then goes inside."
        echo "Usage: mcd <directory>"
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
                echo "	-v, --verbose		Display what is being done"
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
                echo "Invalid parameter, use \"rmspc --help\" to display options list"
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