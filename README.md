# Alfred

Alfred es un ecosistema modular de scripts para Zsh diseñado para centralizar tareas de mantenimiento, notificaciones y automatización de sistemas Linux. Su arquitectura permite añadir comandos de forma sencilla manteniendo un sistema de autocompletado nativo y ejecución tanto interactiva como desatendida.

## 1. Instalación

### Para instalar Alfred, sigue estos pasos:

1. **Ubica el proyecto:** Descarga o mueve la carpeta del proyecto a una ruta estable (ej. `/data/workspace/alfred`).
2. **Permisos de ejecución:** Asegúrate de que los archivos principales sean ejecutables:
```bash
chmod +x /data/workspace/alfred/alfred.zsh
chmod +x /data/workspace/alfred/commands/*
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

Todos los comandos deben colocarse en la carpeta: $ALFRED_ROOT/commands/.

### Convenciones y Autocompletado

Para que el autocompletado de Zsh reconozca las opciones de tu comando, el script debe implementar el flag --list. Este flag debe imprimir las opciones disponibles separadas por espacios.

### La función alfred_notify

Tienes disponible la función alfred_notify "mensaje" "icono" para enviar notificaciones visuales al escritorio. Esta función es robusta y funciona incluso cuando el script es ejecutado por el usuario root a través de Anacron, detectando automáticamente la sesión del usuario físico.


### Ejemplo: Comando "Hello World" (hello)

Crea el archivo $ALFRED_ROOT/commands/hello y dale permisos de ejecución:

```bash
#!/usr/bin/env zsh

# 1. Definición de sub-parámetros
local -a sub_params
sub_params=(world sir)

# 2. Soporte para autocompletado (Alfred llama a esto internamente)
if [[ " $* " == *" --list "* ]]; then
    echo "${(j: :)sub_params}"
    return 0
fi

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
