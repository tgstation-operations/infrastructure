#!/usr/bin/env bash

echo ""
echo "Welcome to"

cat <<EOF
▗▄▄▖ ▗▖    ▗▄▖  ▗▄▄▖▗▖ ▗▖
▐▌ ▐▌▐▌   ▐▌ ▐▌▐▌   ▐▌▗▞▘
▐▛▀▚▖▐▌   ▐▌ ▐▌▐▌   ▐▛▚▖ 
▐▙▄▞▘▐▙▄▄▖▝▚▄▞▘▝▚▄▄▖▐▌ ▐▌
                         
▗▖  ▗▖ ▗▄▖▗▄▄▄▖▗▖ ▗▖ ▗▄▄▖
▐▛▚▞▜▌▐▌ ▐▌ █  ▐▌ ▐▌▐▌   
▐▌  ▐▌▐▌ ▐▌ █  ▐▛▀▜▌ ▝▀▚▖
▐▌  ▐▌▝▚▄▞▘ █  ▐▌ ▐▌▗▄▄▞▘    

EOF

happy_moth_phrases=(
    "Buzz!"
    "Works in zero gravity!"
    "Definitely won't stab you in maintenance!"
    "Queen of the medbay!"
    "Help I'm trapped in an admin complaint!"
    "We got rid of the nanites!"
)

echo "${happy_moth_phrases[$RANDOM % ${#happy_moth_phrases[@]}]}"
