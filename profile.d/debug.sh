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
    return $errcode
}


# ------------------------------------------------------------------------------
# Activate or deactivate error trapping to display backtrace
# ------------------------------------------------------------------------------
settrace ()
{
    local status="off"
    [[ $(trap -p ERR) ]] && status="on"
    #trap -p ERR
    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
		echo "Try to activate backtrace display for script debugging."
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
		if [[ $status == "on" ]]; then
		    disp W "ERR signal trap is already set, replacing previous trap!"
		fi
		trap "error" ERR
		;;
	    "--off")
		if [[ $status != "on" ]]; then
		    disp W "ERR signal trap is already unset!"
		fi
		trap - ERR
		;;
	    "--status")
		disp "ERR trap signal is ${status}."
		;;
	esac
    done
    unset status
}
export -f settrace
