# ------------------------------------------------------------------------------
# Copyright (c) 2013-2022 Geoffray Levasseur <fatalerrors@geoffray-levasseur.org>
# Protected by the BSD3 license. Please read bellow for details.
#
# * Redistribution and use in source and binary forms,
# * with or without modification, are permitted provided
# * that the following conditions are met:
# *
# *   Redistributions of source code must retain the above
# *   copyright notice, this list of conditions and the
# *   following disclaimer.
# *
# *   Redistributions in binary form must reproduce the above
# *   copyright notice, this list of conditions and the following
# *   disclaimer in the documentation and/or other materials
# *   provided with the distribution.
# *
# *   Neither the name of the copyright holder nor the names
# *   of any other contributors may be used to endorse or
# *   promote products derived from this software without
# *   specific prior written permission.
# *
# * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# * OF SUCH DAMAGE.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Let the rain fall
# ------------------------------------------------------------------------------
rain()
{
    local exit_st=0
    local rain_cars=("|" "│" "┃" "┆" "┇" "┊" "┋" "╽" "╿")
    local rain_colors=("\e[37m" "\e[37;1m")
    # More from 256 color mode
    for i in {244..255}; do
        rain_colors=( "${rain_colors[@]}" "\e[38;5;${i}m" )
    done
    local rain_tab=${#rain_cars[@]}
    local rain_color_tab=${#rain_colors[@]}
    local num_rain_metadata=5
    local term_height=$(tput lines)
    local term_width=$(tput cols)
    local step_duration=0.050
    local X=0 Y=0 drop_length=0 rain_drop=0
    local max_rain_width=0 new_rain_odd=0 falling_odd=0


    sigwinch() {
        term_width=$(tput cols)
        term_height=$(tput lines)
        #step_duration=0.025
        (( max_rain_width = term_width * term_height / 4 ))
        (( max_rain_height = term_height < 10 ? 1 : term_height / 10 ))
        # In percentage
        (( new_rain_odd = term_height > 50 ? 100 : term_height * 2 ))
        (( new_rain_odd = new_rain_odd * 75 / 100 ))
        (( falling_odd = term_height > 25 ? 100 : term_height * 4 ))
        (( falling_odd = falling_odd * 90 / 100 ))
    }

    do_exit() {
        exit_st=1
    }

    do_render() {
        # Clean screen first
        local idx=0
        for ((idx = 0; idx < num_rains * num_rain_metadata; idx += num_rain_metadata)); do
            X=${rains[idx]}
            Y=${rains[idx + 1]}
            drop_length=${rains[idx + 4]}
            for ((y = Y; y < Y + drop_length; y++)); do
                (( y < 1 || y > term_height )) && continue
                echo -ne "\e[${y};${X}H "
            done
        done

        for ((idx = 0; idx < num_rains * num_rain_metadata; idx += num_rain_metadata)); do
            if (( 100 * RANDOM / 32768 < falling_odd )); then
                # Falling
                if (( ++rains[idx + 1] > term_height )); then
                    # Out of screen, bye sweet <3
                    rains=("${rains[@]:0:idx}"
                        "${rains[@]:idx+num_rain_metadata:num_rains*num_rain_metadata}")
                    (( num_rains-- ))
                    continue
                fi
            fi
            X=${rains[idx]}
            Y=${rains[idx + 1]}
            rain_drop=${rains[idx + 2]}
            drop_color=${rains[idx + 3]}
            drop_length=${rains[idx + 4]}
            for ((y = Y; y < Y + drop_length; y++)); do
                (( y < 1 || y > term_height )) && continue
                echo -ne "\e[${y};${X}H${drop_color}${rain_drop}"
            done
        done
    }

    trap do_exit TERM INT
    trap sigwinch WINCH
    # No echo stdin and hide the cursor
    stty -echo
    echo -ne "\e[?25l"

    echo -ne "\e[2J"
    local rains=()
    local num_rains=0
    sigwinch
    while (( exit_st <= 0 )); do
        if (( $exit_st <=0 )); then
            read -n 1 -t $step_duration ch
            case "$ch" in
                q|Q)
                    do_exit
                ;;
            esac

            if (( num_rains < max_rain_width )) && (( 100 * RANDOM / 32768 < new_rain_odd )); then
                # Need new |, 1-based
                rain_drop="${rain_cars[rain_tab * RANDOM / 32768]}"
                drop_color="${rain_colors[rain_color_tab * RANDOM / 32768]}"
                drop_length=$(( max_rain_height * RANDOM / 32768 + 1 ))
                X=$(( term_width * RANDOM / 32768 + 1 ))
                Y=$(( 1 - drop_length ))
                rains=( "${rains[@]}" "$X" "$Y" "$rain_drop" "$drop_color" "$drop_length" )
                (( num_rains++ ))
            fi

            # Let rain fall!
            do_render
        fi
    done
    echo -ne "\e[${term_height};1H\e[0K"

    # Show cursor and echo stdin
    echo -ne "\e[?25h"
    stty echo
    unset exit_st
    trap - TERM INT
    trap - WINCH
}
export -f rain
