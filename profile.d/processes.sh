# ------------------------------------------------------------------------------
# Search processes matching the given string
# ------------------------------------------------------------------------------
ppg ()
{
    ps -edf | grep $@ | grep -v "grep $@"
}
export -f ppg


# ------------------------------------------------------------------------------
# Get PID list of the given process name
# ------------------------------------------------------------------------------
gpid ()
{
    [[ $UID -eq 0 ]] && local psopt="-A"
    [[ $# -eq 1 ]] && local single=1
    for pid in $@; do
        local result=$(ps $psopt | grep $pid | awk '{print $1}' | sed "s/\n/ /")
        if [[ $single ]]; then
            [[ $result ]] && echo "${result//$'\n'/ }"
        else
            [[ $result ]] && echo "$pid: ${result//$'\n'/ }"
        fi
    done
    [[ $result ]] || return 1
}
export -f gpid


# ------------------------------------------------------------------------------
# Kill all processes owned by the given users
# ------------------------------------------------------------------------------
ku ()
{
    for u in $@; do
        killall -u $u
    done
}
export -f ku
