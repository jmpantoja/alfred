#!/usr/bin/env zsh
source "$ALFRED_UTILS"

local desc="Comando de prueba."
local -a sub_params=(world sir)

local cmd="${0:A:h:t}"
local help=$(alfred_help_message "$cmd" "$desc" "${sub_params[@]}")

alfred_help "$help" "$@" && return 0
alfred_list "${sub_params[@]}" "$@" && return 0

# 3. Lógica del comando
case "$1" in
    world)
        echo "¡Hola Mundo!"
        alfred_notify "¡Hola Mundo! El sistema está operativo." "face-smile"
        ;;
    sir)
        echo "A sus órdenes, señor."
        alfred_notify "A sus órdenes, señor." "utilities-terminal"
        ;;
    *)
        echo $help
        return 1
        ;;
esac
