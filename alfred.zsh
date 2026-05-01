# Obtenemos la ruta absoluta del directorio donde reside este script
export ALFRED_ROOT="${0:A:h}"

# 2. Añadirse a sí mismo al fpath de Zsh si no está ya
if [[ "${fpath[(r)$ALFRED_ROOT]}" != "$ALFRED_ROOT" ]]; then
    fpath=("$ALFRED_ROOT" $fpath)
fi

# Función para enviar notificaciones al usuario físico desde root
alfred_notify() {
    local msg="$1"
    local icon="${2:-utilities-terminal}" # Icono por defecto

    # Buscamos al usuario real que tiene la sesión X11/Wayland abierta
    #local real_user=$(who | awk '{print $1}' | head -n1)
    local real_user=pato
    local user_id=$(id -u "$real_user")

    if [[ -n "$real_user" ]]; then
        sudo -u "$real_user" \
        DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$user_id"/bus \
        notify-send "🎩 Alfred" "$msg" --icon="$icon" -u critical
    else
        echo "Alfred: No se detectó una sesión de usuario activa para notificar."
    fi
}

function alfred() {
    if [[ $# -eq 0 ]]; then
        echo "Dígame, señor. ¿En qué puedo ayudarle?"
        echo "Comandos disponibles en $ALFRED_ROOT/commands/:"
        ls "$ALFRED_ROOT/commands"
        return 0
    fi

    local cmd=$1
    shift
    local cmd_path="$ALFRED_ROOT/commands/$cmd"

    if [[ -f "$cmd_path" ]]; then
        # Ejecutamos el comando pasando el resto de argumentos
        source "$cmd_path" "$@"
    else
        echo "Alfred: El comando '$cmd' no existe en la baticueva."
    fi
}
