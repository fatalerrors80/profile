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
                disp E "Invalid option, use \"utaz --help\" to display options list"
                echo
                return 1
                ;;

            *)
                # The ${opt%/} writing is to remove trailing / if any
                local LIST="$LIST ${opt%/}"
                ;;
        esac
    done

    [[ $createdir && $nodir ]] && disp E "The --create-dir and --no-dir options are mutually exclusive."

    [[ ! $LIST ]] && local LIST="."

    for zitem in $LIST; do
        [[ $(ls $zitem/*.zip 2> /dev/null | wc -l) -eq 0 ]] &&
            disp W "$zitem contains no supported archive file, skipping." &&
            continue

        for f in $zitem/*.zip; do
            disp I "Processing archive $zitem/$f... "
            local dir=${f::-4}

            mkdir -p $dir
            [[ $? -gt 0 ]] &&
                disp E "The filesystem can't create directories, exit!" &&
                return 1

            unzip -o $f -d $dir > /dev/null 2>&1
            case $? in
                0)
                    [[ $willrm ]] && rm -f $f && disp I "File $zitem/$f deleted."
                    ;;

                1)
                    disp W "Compression program returned a warning: deletion canceled."
                    ;;
                *)
                    disp E "The zip file seems corrupted, failed."
                    rm -rf $dir > /dev/null 2>&1
                    continue
                    ;;
            esac

            if [[ $createdir ]]; then
                disp I "Archive extracted successfully in subdirectory."
            elif [[ $nodir ]]; then
                mv ./$dir/* ./ && rmdir $dir
                disp I "Archive extracted successfully, no subdirectory needed."
            else
                subdirs=$(find $dir -maxdepth 1 | wc -l)
                if [[ $subdirs -eq 2 ]]; then
                    mv ./$dir/* ./ && rmdir $dir
                    disp I "Archive extracted successfully, no subdirectory needed."
                else
                    disp I "Archive extracted successfully in subdirectory."
                fi
            fi
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
            disp E "The program 'xz' is not installed, aborting."
            return 127
        }

        [[ $4 ]] && local verb='-v'

        # Display a warning for this format
        disp W "xz format is not suited for long term archiving."
        disp I "See https://www.nongnu.org/lzip/xz_inadequate.html for details."

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
                disp E "Program 'plzip' or 'lzip' are not installed, aborting."
                return 127
            }
            local command=lzip
            local procopt=""
            [[ $2 -gt 1 ]] &&
                disp W "lzip doesn't support multithreading, falling back to 1 thread." &&
                disp W "Consitder installing plzip to obtain multithreading abilities."
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
                disp E "Programs 'pigz' or 'gzip' are not installed, aborting."
                return 127
            }
            local command="gzip --compress"
            local procopt=""
            [[ $2 -gt 1 ]] &&
                disp W "gzip doesn't support multithreading, falling back to 1 thread." &&
                disp W "Consitder installing pigz to obtain multithreading abilities."
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
                disp E "The program 'pbzip2' or 'bzip2' are not installed, aborting."
                return 127
            }
            local command=bzip2
            local procopt=""
            [[ $2 -gt 1 ]] &&
                disp W "bzip2 doesn't support multithreading, falling back to 1 thread." &&
                disp W "Consitder installing pbzip2 to obtain multithreading abilities."
        }

        [[ $4 ]] && local verb="-v"

        # Compresse au format bz2
        $command $verb --compress $procopt --keep -$3 $1
        return $?
    }

    _dolzo()
    {
        command -v lzop >/dev/null 2>&1 || {
            disp E "The program 'lzop' is not installed, aborting."
            return 127
        }

        [[ $4 ]] && local verb='-v'
        [[ $2 -gt 1 ]] && disp W "lzop doesn't support multithreading, falling back to 1 thread."

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
                echo "	-q, --quiet	Display less messages (only errors and warnings)"
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

	    "-q"|"--quiet")
		QUIET=1

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
    [[ $verbose -gt 1 && $QUIET -gt 1 ]] &&
	disp E "The --verbose and --quiet options can't be used together."

    for item in $LIST; do
        local donetar=0
        disp I "Processing $item..."

        if [[ -d $item ]]; then
            disp I "\t Creating $item.tar... "

            tar -cf $item{.tar,}
            if [[ ! $? -eq 0 ]]; then
                disp E "tar file creation failed, skipping to next item."
                continue
            fi

            local donetar=1
        fi

        local fname=$item
        [[ $donetar -gt 0 ]] && fname=$item.tar

        # Skip compression part if tar is asked
        if [[ $compform != "tar" ]]; then
            disp I "\t Compressing archive..."
            _do$compform $fname $nproc $complevel $verbose
            [[ ! $? -eq 0 ]] && case $? in
                127)
                    disp E "Compression program unavailable, aborting."
                    return 127
                    ;;
                *)
                    disp E "Compression program returned an error, not deleting anything if asked, skipping to next item."
                    continue
                    ;;
            esac

            [[ $donetar -gt 0 ]] && rm $fname
        fi

        if [[ $willrm ]]; then
            disp I "\t Deleting original source as asked... "
            rm -r $item
        fi
    done
    unset QUIET
}
export -f taz
