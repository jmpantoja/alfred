# Alfred

Alfred es un ecosistema modular de scripts para Zsh diseñado para centralizar tareas de mantenimiento, notificaciones y automatización de sistemas Linux. Su arquitectura permite añadir comandos de forma sencilla manteniendo un sistema de autocompletado nativo y ejecución tanto interactiva como desatendida.

## 1. Instalación

### Para instalar Alfred, sigue estos pasos:

1. **Ubica el proyecto:** Descarga o mueve la carpeta del proyecto a una ruta estable (ej. `/data/workspace/alfred`).
2. **Permisos de ejecución:** Asegúrate de que los archivos principales sean ejecutables:
```bash
chmod +x /data/workspace/alfred/alfred.zsh
chmod +x /data/workspace/alfred/commands/*/main.zsh
```

### Integración en .zshrc

Para que Alfred esté disponible en cada sesión de terminal, añade las siguientes líneas a tu archivo ~/.zshrc:

```bash
# Carga de Alfred
export ALFRED_ROOT="/data/workspace/alfred"
source "$ALFRED_ROOT/alfred.zsh"
```

## 2. Cómo crear un nuevo comando

Alfred es modular. Cada comando es un script independiente que reside en una carpeta específica.

### Ubicación

Todos los comandos deben colocarse en la carpeta: $ALFRED_ROOT/commands/<name>/main.zsh.

### Convenciones y 
**Autocompletado**
Para que el autocompletado de Zsh reconozca las opciones de tu comando, el script debe implementar el flag --list. Este flag debe imprimir las opciones disponibles separadas por espacios.

**Ayuda**
Para que el parametro -h funcione, el script debe implementar el flag -h. Este flag debe imprimir el mensaje de ayuda / descripción del comando.

### Variables
En cada subcomando, se definen las siguientes variables locales para automatizar su comportamiento:
**desc**: Una cadena de texto que describe brevemente la función del comando.
**sub_params**: Un array (local -a) que contiene los subcomandos o flags válidos. Se utiliza tanto para la ayuda visual como para el sistema de autocompletado.  
**cmd**: Se calcula dinámicamente usando ${0:A:h:t}. Esto extrae el nombre de la carpeta que contiene el script, asegurando que si renombras el directorio, el comando se actualice automáticamente.
**help**: Almacena el mensaje de ayuda preformateado generado por la función de utilidad, facilitando su reutilización en errores o solicitudes de ayuda.  


### Utilidades
El archivo utils.zsh provee la lógica compartida para todos los comandos de Alfred:
**alfred_help_message**
Se encarga de unificar la estética de la ayuda. Recibe el nombre del comando, la descripción y los parámetros para devolver un bloque de texto formateado (ej. con prefijos como > y estructuras de uso.  

**alfred_help**
Gestiona la intercepción del flag -h. Verifica si el argumento de ayuda está presente en la ejecución actual ($@); si es así, imprime el mensaje de ayuda y detiene la ejecución del script devolviendo un estado exitoso (return 0).

**alfred_list**
Es el motor del autocompletado dinámico. Cuando el sistema de autocompletado de Zsh (_alfred) solicita los parámetros mediante el flag --list, esta función filtra los argumentos y devuelve únicamente la lista de sub_params en formato de texto plano.

**alfred_notify**
Proporciona un sistema de notificaciones de escritorio persistente. Está diseñada para detectar si el script se ejecuta con sudo y, mediante la identificación del usuario real (SUDO_UID), redirigir la notificación al bus de sesión del usuario para que aparezca correctamente en el entorno gráfico.

### Ejemplo: Comando "Hello World" (hello)

Crea el archivo $ALFRED_ROOT/commands/hello/main.zsh y dale permisos de ejecución:

```bash
#!/usr/bin/env zsh

local cmd="${0:A:h:t}"
local desc="Dice Hola."
local -a sub_params=(world sir)
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
        echo "Uso: alfred hello {world|sir}"
        return 1
        ;;
esac
```

## 3. Integración con Anacron / Cron

Para ejecutar comandos de Alfred de forma automática y desatendida (ej. diariamente al encender el equipo), sigue este esquema genérico.

### Script disparador

Crea un archivo en /etc/cron.daily/alfred-<task_name> (sin extensión) con el siguiente contenido:

```bash
#!/usr/bin/env zsh

# --- Configuración ---
TASK_NAME="hello"
PATH_TO_ALFRED="/data/workspace/alfred"
LOG_FILE="/var/log/alfred-${TASK_NAME}.log"

# Aseguramos el PATH para ejecución desatendida
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Esperar a que el sistema esté listo (opcional para tareas rápidas)
# sleep 1m

# 1. Cargar Alfred
if [ -f "$PATH_TO_ALFRED/alfred.zsh" ]; then
    source "$PATH_TO_ALFRED/alfred.zsh"
else
    # Si falla la carga, notificamos en un log de error genérico
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ Error: No se encuentra alfred.zsh en $PATH_TO_ALFRED" >> /var/log/alfred-error.log
    exit 1
fi

# 2. Ejecutar la acción
# Añadimos marca de tiempo al inicio de la tarea
echo "\n[$(date '+%Y-%m-%d %H:%M:%S')] >>> Iniciando Alfred: $TASK_NAME" >> $LOG_FILE
alfred hello world >> $LOG_FILE 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] <<< Tarea finalizada." >> $LOG_FILE

# 3. Mantenimiento del Log
# Ajustamos permisos para lectura sin sudo por parte del usuario
chmod 644 $LOG_FILE
```


## 4. Listado de Comandos Actuales
Comando	Parámetros	Descripción
update	all	Realiza mantenimiento completo: Snapshot, Snap, Flatpak, Apt y Firmware.
hello	world, sir	Comando de ejemplo para verificar funcionamiento y notificaciones.

| Comando | Sub-comando | Descripción | Notificación |
| :--- | :--- | :--- | :--- |
| `update` | `all` | Mantenimiento completo del sistema | Sí |
| `hello` | `world` | Ejemplo básico de Alfred | Sí |
| `hello` | `sir` | Comando de ejemplo para verificar funcionamiento y notificaciones | Sí |


## 5. Consideraciones Importantes

    Resiliencia: En los scripts de comandos, evita encadenar herramientas independientes con &&. Es preferible que si falla la actualización de Snaps, el script continúe con los Flatpaks.

    Logs: Las ejecuciones automáticas redirigen la salida a /var/log/. Puedes monitorizar la actividad en tiempo real con:
    tail -f /var/log/alfred-update.log

    Variable ALFRED_ROOT: Esta variable se autogestiona en alfred.zsh calculando la ruta absoluta donde se encuentra el script, lo que hace que el proyecto sea portable a cualquier carpeta.


---
