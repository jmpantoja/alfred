# utils.zsh

alfred_help_message() {
    # Cargamos el módulo de colores de Zsh si no está disponible
        autoload -U colors && colors

        local cmd="$1"
        local desc="$2"
        shift 2
        local -a params=($*)

        # Construcción del mensaje con formato mejorado
        # %F{color} abre el color, %f lo cierra
        local header="$fg_bold[cyan] alfred $fg_bold[white]$cmd$reset_color"
        local description="$fg[grey]$desc$reset_color"

        local usage_line
        if (( ${#params} > 0 )); then
            # Resaltamos los parámetros en amarillo y con separadores claros
            usage_line=" ${fg[yellow]}alfred $cmd${reset_color} [${(j:|:)params}]"
        else
            usage_line="${fg[yellow]}alfred $cmd${reset_color}"
        fi

        # Resultado final con saltos de línea estratégicos
        echo "\n${header}: ${description}"
        echo "${usage_line}\n"
}

# Comprueba si se ha pedido ayuda y la imprime
alfred_help() {
    local help_text="$1"
    if [[ " $* " == *" -h "* ]]; then
        echo "$help_text"
        return 0
    fi
    return 1
}

# Responde a la petición de autocompletado
alfred_list() {
    # 1. Buscamos si '--list' está en los argumentos de forma exacta
    if [[ " $@ " == *" --list "* ]]; then

            # 2. Filtramos el array $@ eliminando EXACTAMENTE '--list'
            # La sintaxis :# elimina los elementos que coinciden con el patrón
            local -a result
            result=( ${@:#--list} )

            # 3. Imprimimos la lista limpia
            echo "${(j: :)result}"
            return 0
        fi
        return 1
}

# Notificaciones
alfred_notify() {
    local msg="$1"
    local icon="${2:-utilities-terminal}"
    USER_ID=${SUDO_UID:-1000}
    REAL_USER=$(id -nu "$USER_ID")

    if [[ -n "$REAL_USER" ]]; then
        sudo -u "$REAL_USER" \
        DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$USER_ID"/bus \
        notify-send "🎩 alfred" "$msg" --icon="$icon"
    fi
}
