# ------------------------------------------------------------------------------
# Show profile version
# ------------------------------------------------------------------------------
ver ()
{
    echo "Profile version $PROFVERSION."
}
export -f ver


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
# Display system general information
# ------------------------------------------------------------------------------
showinfo()
{
    echo -e "\n"
    if command -v figlet >/dev/null 2>&1; then 
	figlet -k $(hostname)
    else
	echo "$(hostname -f)"
    fi
    echo ""
    if command -v neofetch >/dev/null 2>&1; then
	neofetch
    else
	(
	    if [[ -s /etc/os-release ]]; then
		. /etc/os-release
		echo "$NAME $VERSION"
	    else
		cat /proc/version
	    fi
	    echo "Uptime: $(uptime)"
	)
    fi
}
export -f showinfo
