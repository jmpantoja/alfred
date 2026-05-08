#!/usr/bin/env zsh
source "$ALFRED_UTILS"

local desc="Actualiza el sistema."
local -a sub_params=(world sir)

local cmd="${0:A:h:t}"
local help=$(alfred_help_message "$cmd" "$desc" "${sub_params[@]}")

alfred_help "$help" "$@" && return 0
alfred_list "${sub_params[@]}" "$@" && return 0

# 3. Lógica del comando
case "$1" in
    all)
        echo "-------------------------------------------"
        echo "📸 Alfred: Creando snapshot de seguridad..."
        echo "-------------------------------------------"
        sudo timeshift --create --comments "alfred daily" --tags D 2>/dev/null

        echo "------------------------"
        echo "📦 Actualizando Snaps..."
        echo "------------------------"
        sudo snap refresh

        echo "---------------------------"
        echo "📦 Actualizando Flatpaks..."
        echo "---------------------------"
        sudo flatpak update -y
        flatpak uninstall --unused -y

        echo "------------------------------------------"
        echo "🏛️  Actualizando base del sistema (Apt)..."
        echo "------------------------------------------"
        # DEBIAN_FRONTEND=noninteractive evita que Apt intente abrir diálogos
        sudo DEBIAN_FRONTEND=noninteractive apt update && sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
        sudo apt autoremove -y
        sudo apt autoclean

        echo "---------------------------"
        echo "💻 Actualizando Firmware..."
        echo "---------------------------"
        # Usamos || true para que si no hay updates no cuente como error
        sudo fwupdmgr get-updates -y || true
        sudo fwupdmgr update -y --assume-yes


	# 4. Notificación final
    if [ $? -eq 0 ]; then
       	# Si todo ha ido bien
		alfred_notify "Mantenimiento completado con éxito. Sistema al día." "utilities-terminal"
	else
       	# Si algo falló en el último comando
         alfred_notify "Ojo, algo no ha salido bien. Revisa /var/log/alfred-update.log" "dialog-error"
	fi

	# 5. Aviso específico de reinicio (si es necesario)
	if [ -f /var/run/reboot-required ]; then
	    alfred_notify "Se requiere reiniciar para aplicar cambios críticos." "system-reboot"
	fi

        ;;
    *)
        echo $help
        return 1
        ;;
esac
