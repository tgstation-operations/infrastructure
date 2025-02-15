#!/bin/bash

echo ""
echo "Welcome to" | sed -e :a -e "s/^.\{1,65\}$/ & /;ta"

cat <<EOF

▄▄▄█████▓  ▄████   ██████  ▄▄▄     ▄▄▄█████▓ ▄▄▄       ███▄    █
▓  ██▒ ▓▒ ██▒ ▀█▒▒██    ▒ ▒████▄   ▓  ██▒ ▓▒▒████▄     ██ ▀█   █
▒ ▓██░ ▒░▒██░▄▄▄░░ ▓██▄   ▒██  ▀█▄ ▒ ▓██░ ▒░▒██  ▀█▄  ▓██  ▀█ ██▒
░ ▓██▓ ░ ░▓█  ██▓  ▒   ██▒░██▄▄▄▄██░ ▓██▓ ░ ░██▄▄▄▄██ ▓██▒  ▐▌██▒
  ▒██▒ ░ ░▒▓███▀▒▒██████▒▒ ▓█   ▓██▒ ▒██▒ ░  ▓█   ▓██▒▒██░   ▓██░
  ▒ ░░    ░▒   ▒ ▒ ▒▓▒ ▒ ░ ▒▒   ▓▒█░ ▒ ░░    ▒▒   ▓▒█░░ ▒░   ▒ ▒
    ░      ░   ░ ░ ░▒  ░ ░  ▒   ▒▒ ░   ░      ▒   ▒▒ ░░ ░░   ░ ▒░
  ░      ░ ░   ░ ░  ░  ░    ░   ▒    ░        ░   ▒      ░   ░ ░
               ░       ░        ░  ░              ░  ░         ░

EOF

evil_666_phrases=(
    "It's hell on Earth!"
    "Hell is empty, and all the devils are here!"
    "Sixty-six six! Sixes! Spooky!"
    "Made with spite and regret!"
    "Truly BYOND the impossible!"
    "A g-g-g-g-ghost!"
    "The accursed child itself!"
    "PubbyStation lives!"
    "Home of the fridge (probably)!"
    "Felinids beware!"
    "Bolt the airlocks--don't let it inside!"
    "Ready your plasma cutters!"
    "We got rid of the nanites!"
    "There are no ducks on Space Station 13!"
    "Now with atmospherics simulation!"
    "We didn't start the fire!"
    "Boom Boom Shake the Room!!!"
    "Hell, hell, hell has it's laws"
    "Hell, hell, effects and the cause"
    "Welcome to the ninth circle!"
    "Remember, you're here forever!"
)

echo "${evil_666_phrases[$RANDOM % ${#evil_666_phrases[@]}]}" | sed -e :a -e "s/^.\{1,65\}$/ & /;ta"
