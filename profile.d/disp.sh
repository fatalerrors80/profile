# Color definitions
# ------------------------------------------------------------------------------
# Standard 16 colors display declaration
export DEFAULTFG="\e[0;39m"
export DEFAULTBG="\e[0;49m"
export DEFAULTCOL=${DEFAULTBG}${DEFAULTFG}

# Regular Colors
export Black='\e[0;30m'
export Red='\e[0;31m'
export Green='\e[0;32m'
export Yellow='\e[0;33m'
export Blue='\e[0;34m'
export Purple='\e[0;35m'
export Cyan='\e[0;36m'
export White='\e[0;37m'

# Bold
export BBlack='\e[1;30m'
export BRed='\e[1;31m'
export BGreen='\e[1;32m'
export BYellow='\e[1;33m'
export BBlue='\e[1;34m'
export BPurple='\e[1;35m'
export BCyan='\e[1;36m'
export BWhite='\e[1;37m'

# Underline
export UBlack='\e[4;30m'
export URed='\e[4;31m'
export UGreen='\e[4;32m'
export UYellow='\e[4;33m'
export UBlue='\e[4;34m'
export UPurple='\e[4;35m'
export UCyan='\e[4;36m'
export UWhite='\e[4;37m'

# Background
export On_Black='\e[40m'
export On_Red='\e[41m'
export On_Green='\e[42m'
export On_Yellow='\e[43m'
export On_Blue='\e[44m'
export On_Purple='\e[45m'
export On_Cyan='\e[46m'
export On_White='\e[47m'

# High Intensity
export IBlack='\e[0;90m'
export IRed='\e[0;91m'
export IGreen='\e[0;92m'
export IYellow='\e[0;93m'
export IBlue='\e[0;94m'
export IPurple='\e[0;95m'
export ICyan='\e[0;96m'
export IWhite='\e[0;97m'

# Bold High Intensity
export BIBlack='\e[1;90m'
export BIRed='\e[1;91m'
export BIGreen='\e[1;92m'
export BIYellow='\e[1;93m'
export BIBlue='\e[1;94m'
export BIPurple='\e[1;95m'
export BICyan='\e[1;96m'
export BIWhite='\e[1;97m'

# High Intensity backgrounds
export On_IBlack='\e[0;100m'
export On_IRed='\e[0;101m'
export On_IGreen='\e[0;102m'
export On_IYellow='\e[0;103m'
export On_IBlue='\e[0;104m'
export On_IPurple='\e[0;105m'
export On_ICyan='\e[0;106m'
export On_IWhite='\e[0;107m'


# ------------------------------------------------------------------------------
# Display a message
# ------------------------------------------------------------------------------
disp()
{
    case $1 in
        "I")
            local heads="[ ${IGreen}info${DEFAULTFG} ]"
            shift
            [[ -z $QUIET || $QUIET -ne 1 ]] && echo -e "${heads} $@"
            ;;
        "W")
            local heads="[ ${IYellow}Warning${DEFAULTFG} ]"
            shift
            echo -e "${heads} $@" >&2
            ;;
        "E")
            local heads="[ ${IRed}ERROR${DEFAULTFG} ]"
            shift
            echo -e "${heads} $@" >&2
            ;;
	"D")
	    local heads"[ ${ICyan}debug${DEFAULTFG} ]"
	    shift
	    [[ -n $DEBUG && $DEBUG -gt 1 ]] && echo -e "${heads} $@"
	    ;;
        "*")
            local heads=""
            [[ -z $QUIET || $QUIET -ne 1 ]] && echo -e "$@"
            ;;
    esac
    unset heads
}
export -f disp
