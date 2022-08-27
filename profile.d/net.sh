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
	fi
    fi
    if [[ -t 1 ]]; then
	echo "The given parameter is NOT a valid IPv4."
    fi
    return 1
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
    fi
    if [[ -t 1 ]]; then
	echo "The given parameter is not a valid IPv6."
    fi
    return 1
}
export -f isipv6
