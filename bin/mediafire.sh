#! /usr/bin/env bash
#===============================================================================
#
#          FILE: mediafire.sh
#
#         USAGE: ./mediafire.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: aeelinn
#  ORGANIZATION:
#       CREATED: 24/09/13 23:01:15 CDT
#      REVISION:  ---
#===============================================================================

# Font Colors -----------------------------------------------------------------
 F_BLACK=30;  F_RED=31;   F_GREEN=32;  F_YELLOW=33; F_BLUE=34;
F_PURPLE=35;  F_CYAN=36;  F_GRAY=37;   F_WHITE=38;

# Background Colors -----------------------------------------------------------
 B_BLACK=40;  B_RED=41;   B_GREEN=42;  B_YELLOW=43; B_BLUE=44;
B_PURPLE=45;  B_CYAN=46;  B_GRAY=47;

# Formats ---------------------------------------------------------------------
BOLD=01;  ITALIC=03  UNDER=04;  BLINK=05;  REVERSE=07;

function cout() {
    printf "[$1m""$2""[0m"
}

function init_regex() {
    cout "$BOLD;$F_GREEN" "    init_regex... "

    # Variables
    user_agent='Windows 9 Alpha'
    cnt=0

    # Files
    smp_file="$(mktemp /tmp/smp.XXXXXXXXXX)"  # Sample file
    rgx_file="$(mktemp /tmp/rgx.XXXXXXXXXX)"  # Regex file
    swp_file="$(mktemp /tmp/swp.XXXXXXXXXX)"  # Swap file
    lnk_file="$(mktemp /tmp/lnk.XXXXXXXXXX)"  # Link file

    cout "$BOLD;$F_GREEN" "done\n"
}

function set_HTTP_sample() {
    torsocks wget -qU "$user_agent" -O $smp_file $1 2> /dev/null
    restore_sample
}

function restore_sample() {
    cp $smp_file $rgx_file
}

function draw_regex() {
    grep -Eio "$1" $rgx_file > $swp_file
    cp $swp_file $rgx_file
}

function get_file_link() {
    draw_regex 'href="https://download[^"]+"'
    draw_regex '"[^"]+"'
    draw_regex '[^"]+'
}

function get_file_name () {
    draw_regex '<div class="filename">[^<]+</div>'
    draw_regex '>[^<]+'
    draw_regex '[^>]+'

    file_name=$(cat $rgx_file | head -n 1)
}

#  Main script
init_regex

#  Arguments loop
for url in $@; do
    set_HTTP_sample "$url"
    ((cnt+=1))

    get_file_name
    cout "$BOLD;$F_GREEN" "Mediafire[$cnt]: $file_name\n"

    restore_sample
    get_file_link

    cat $rgx_file >> $lnk_file
done

#  Download section
[ -s $rgx_file ] && torsocks wget -U "$user_agent" -ct0 -i $lnk_file
