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
                local complevel=$(echo $opt | sed 's/-//')
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
