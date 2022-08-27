# ------------------------------------------------------------------------------
# Look for a package within installed one
# ------------------------------------------------------------------------------
dpkgs ()
{
    local count=0
    for opt in $@ ; do
        case $opt in
            "-h"|"--help")
                echo "dpkgs: look for an installed package by it's name."
                echo
                echo "Usage: dpkgs <string>"
                return 0
                ;;

            "-"*)
                echo "Invalid option, use \"dpkgs --help\" to display usage."
                echo
                return 1
                ;;

            *)
                local pkg=$1 && shift
                count=$(( $count + 1 ))
                [[ $count -gt 1 ]] &&
                    echo "*** Error: Please specify a package name, without space, eventually partial." &&
                    return 1

                ;;
        esac
    done
    [[ $count -lt 1 ]] &&
        echo "*** Error: Please specify a package name, without space, eventually partial." &&
        return 1

    [[ -x /usr/sbin/dpkg ]] &&
        echo "*** Error: dpkg command seems unavialable." &&
        return 2

    dpkg -l | grep $pkg
}
export -f dpkgs
