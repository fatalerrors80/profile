# ------------------------------------------------------------------------------
# Change locale to French
# ------------------------------------------------------------------------------
setfr ()
{
    # Set fr locale definitions
    export LANG=fr_FR.UTF-8
    export LC_MESSAGES=fr_FR.UTF-8
    export LC_ALL=fr_FR.UTF-8
}
export -f setfr

# ------------------------------------------------------------------------------
# Change locale to C standard
# ------------------------------------------------------------------------------
setc ()
{
    # Locale definitions
    export LANG=C
    export LC_MESSAGES=C
    export LC_ALL=C
}
export -f setc

# ------------------------------------------------------------------------------
# Change locale to US (needed by Steam)
# ------------------------------------------------------------------------------
setus ()
{
    # Locale definitions
    export LANG=en_US.UTF-8
    export LC_MESSAGES=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
}
export -f setus
