---
description: Genera una hoja de ruta técnica detallada para un cambio o nueva funcionalidad y la guarda en el sistema de archivos.
agent: build
---
Analiza el proyecto y escribe un plan detallado con los pasos a seguir para: $ARGUMENTS. 
**Argumentos:**
- `descripcion`: (Obligatorio) Explicación de la funcionalidad o cambio.
- `nombre_archivo`: (Opcional) Nombre específico para el archivo (por defecto: `plan-[timestamp].md`).

**Flujo de ejecución:**
1. Analizar el codebase actual para identificar archivos afectados.
2. Delegar la redacción al **plan**.
3. Guardar el resultado en la ruta establecida: `./docs/plans/`.
4. Notificar al usuario con un enlace al archivo creado.
