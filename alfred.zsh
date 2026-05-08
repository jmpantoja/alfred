# Obtenemos la ruta absoluta del directorio donde reside este script
export ALFRED_ROOT="${0:A:h}"
export ALFRED_UTILS="$ALFRED_ROOT/utils.zsh"

# 2. Añadirse a sí mismo al fpath de Zsh si no está ya
if [[ "${fpath[(r)$ALFRED_ROOT]}" != "$ALFRED_ROOT" ]]; then
    fpath=("$ALFRED_ROOT" $fpath)
fi


alfred_help_show() {
    for script in ./commands/*/main.zsh; do
        echo "$($script -h) \n"
    done
    echo "\n"
    return 0
}

alfred_not_found(){
    autoload -U colors && colors
    echo "\n"
    echo "> El comando $fg[red]$1$reset_color no existe"
    alfred_help_show
    return 0
}


function alfred() {
    if [[ $# -eq 0 ]]; then
        alfred_help_show
        return 1
    fi

    local cmd=$1
    shift

    if [[ "$cmd" == '-h' ]]; then
        alfred_help_show
        return 0
    fi

    local cmd_path="$ALFRED_ROOT/commands/$cmd/main.zsh"

    if [[ -f "$cmd_path" ]]; then
        # Ejecutamos el comando pasando el resto de argumentos
        source "$cmd_path" "$@"
    else
        alfred_not_found $cmd
        return 1
    fi
}
