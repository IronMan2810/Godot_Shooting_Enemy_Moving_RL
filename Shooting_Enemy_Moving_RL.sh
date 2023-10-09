#!/bin/sh
echo -ne '\033c\033]0;Shooting_Rl_Enemy_Moving\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Shooting_Enemy_Moving_RL.x86_64" "$@"
