# ------------------------------------------------------------------------------
# Display list of commands and general informations
# ------------------------------------------------------------------------------
help ()
{
    cat <<EOF
clean		Erase backup files
dpkgs		Search for the given package in the installed ones 
gpid		Give the list of PIDs for the given process name
isipv4		Tell if the given IPv4 is valid
isipv6		Tell if the given IPv6 is valid
mcd		Create a directory and go inside
meteo		Display curent weather forecast for the configured city
ppg		Display process matching the given parameter
rain		Let the rain fall
rmhost		Remove host (IP and/or DNS name) for current known_host
rmspc		Remove spaces from all the files in working directory
setc		Set console language to C
setfr		Set console language to French
settrace	Activate/deactivate call trace for script debugging
setus		Set console language to US English
showinfo	Show the welcoming baner with basic system information
ssr		Do a root login to the given address
taz		Compress smartly the given files or directory
utaz		Uncompress all zip files in the given (or current) directory
ver		Display version of your copy of profile

EOF
}
export -f help

