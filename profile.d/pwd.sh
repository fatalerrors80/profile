# ------------------------------------------------------------------------------
# genpwd : generate a password with different criteria
# default 16 car with up and low car, symbol and number
# The function is very slow on Windows
# ------------------------------------------------------------------------------
genpwd()
{
    local length=16
    local occurs=2 # Bug, if set to 1, seems to be ignored
    local symb=1 maj=1 min=1 numb=1
    local nbpwd=1
    
    for opt in $@; do
	case $opt in
	    "-h"|"--help")
		echo "genpwd: generate a secure random password."
		echo
		echo "Usage: genpwd [options] [--extracars=<cars>] [--length=<n>] [nb_passwd]"
		echo
		echo "Options:"
		echo "	-h, --help	Display that help screen"
		echo "	-s, --nosymbols	Exclude symbols"
		echo "	-n, --nonumbers	Exclude numbers"
		echo "	-u, --noup	Exclude uppercase letters"
		echo "	-l, --nolow	Exclude lowercase letters"
		echo "	-e=<c>, --extracars=<c>"
		echo "			Add the given caracters to the possible caracter list"
		echo "	-L=<n>, --length=<n>"
		echo "			Set length of the password (default is $length)"
		echo "	-o=<n>, --occurences=<n>"
		echo "			Set the maximum occurences of a same caracter (default is $occurs)"
		echo
		echo "If the --extracars parameter is given, at least one of the given caracter will"
		echo "be used in the final password."
		echo
		echo "Please note that some caracters might be interpreted by Bash or Awk programs,"
		echo "and thus, cannot be used without provoquing errors. Those identified caracters"
		echo "are :"
		echo '	* ? \ $ { }'
		echo
		return 0
		;;
	    "-s"|"--nosymbols")
		symb=0
		;;
	    "-n"|"--nonumbers")
		numb=0
		;;
	    "-u"|"--noup")
		maj=0
		;;
	    "-l"|"--nolow")
		min=0
		;;
	    "-e"?*|"--extracars"?*)
		local extcar=$(echo "$opt" | cut -f 2- -d '=')
		;;
	    "-L"?*|"--length"?*)
		local length=$(echo "$opt" | cut -f 2- -d '=')
		if ! [[ $length =~ ^[0-9]+$ ]]; then
		    disp E "The --length parameter requires a number."
		    return 1
		fi
		;;
	    "-o"?*|"--occurences"?*)
		local occurs=$(echo "$opt" | cut -f 2- -d '=')
		if ! [[ $occurs =~ ^[1-9]+$ ]]; then
		    disp E "The --occurs parameter requires a number from 1 to 9."
		    return 1
		fi
		;;
	    "-*")
		disp E "Unknow parameter ${opt}."
		return 1
		;;
	    *)
		if ! [[ $opt =~ ^[1-9]+$ ]]; then
		    disp E "Unknow parameter ${opt}."
		    return 1
		else
		    local nbpwd=$opt
		fi
		;;
	esac
    done

    # Function selecting a random caracter from the list in parameter
    pickcar()
    {
	# When a character is picked we check if it's not appearing already twice
	# elsewhere, we choose an other char, to compensate weak bash randomizer
	while [[ -z $char ]]; do
	    local char=$(echo ${1:RANDOM%${#1}:1} $RANDOM)
	    if [[ $(awk -F"$char" '{print NF-1}' <<< "$picked") -gt $occurs ]]; then
		unset char
	    fi
	done
	picked+="$char"
	echo "$char"
    }

    disp I "Generating $nbpwd passwords, please wait..."
    for n in $( seq 1 $nbpwd ); do
	{
	    local carset='' # store final caracter set to use
	    local picked='' # store already used caracter
	    local rlength=0 # store already assigned length of caracters

	    # ?, *, $ and \ impossible to use to my knowledge as it would be interpreted
	    if [[ $symb == 1 ]]; then
		pickcar '!.@#&%/^-_'
		carset+='!.@#&%/^-_'
		(( rlength++ ))
	    fi
	    if [[ $numb == 1 ]]; then
		pickcar '0123456789'
		carset+='0123456789'
		(( rlength++ ))
	    fi
	    if [[ $maj == 1 ]]; then
		pickcar 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
		carset+='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
		(( rlength++ ))
	    fi
	    if [[ $min == 1 ]]; then
		pickcar 'abcdefghijklmnopqrstuvwxyz'
		carset+='abcdefghijklmnopqrstuvwxyz'
		(( rlength++ ))
	    fi
	    if [[ -n $extcar ]]; then
		pickcar "$extcar"
		carset+=$extcar
		(( rlength++ ))
	    fi

	    # Check if we have enough car to have something viable
	    if [[ ${#carset} -lt $length ]]; then
		disp E 'Not enought caracters are authorised for the password length.'
		disp E 'Please allow more caracter (preferably) or reduce password lentgh.'
		return 1
	    fi

	    for i in $( seq 1 $(( $length - $rlength )) ); do
		pickcar "$carset"
	    done
	} | sort -R | awk '{printf "%s", $1}'
	unset picked carset rlength
	echo
    done
}
export -f genpwd
