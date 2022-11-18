# ------------------------------------------------------------------------------
# Remove host from know_host (name and IP) for the active user
# ------------------------------------------------------------------------------
rmhost ()
{
    if [[ "$#" -lt 1 ]]; then
        disp E "Incorrect number of parameters."
        disp E "Usage: rmhost <hostname|ip> [hostname2|ip2 [...]]"
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
		disp E "Impossible to extract IP from hostname." &&
		return 1
	fi
	
	if [[ $hst ]]; then
	    disp I "Removing host $hst from ssh known_host..."
	    ssh-keygen -R $hst > /dev/null
	fi
	if [[ $ip ]]; then
	    disp I "Removing IP $ip from ssh known_host..."
	    ssh-keygen -R $ip > /dev/null
	fi
	unset hst ip
    done
}
export -f rmhost


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
        disp E "Please specify the server you want to log in." &&
        return 1

    local srv=$1 && shift

    ssh -Y root@$srv $@
}
export -f ssr
