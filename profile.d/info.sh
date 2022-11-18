# ------------------------------------------------------------------------------
# Show profile version
# ------------------------------------------------------------------------------
ver ()
{
    disp "Profile version $PROFVERSION."
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
        curl https://wttr.in/$city || disp E "Failed fetching datas for $city."
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
	if [[ -s /usr/share/figlet/ansi_shadow.flf ]]; then
	    local figopt="-f ansi_shadow"
	fi
	figlet -k $(hostname) $figopt
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
