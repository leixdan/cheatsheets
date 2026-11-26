# Bash scripting

> Bash es la shell estándar de Linux y también un lenguaje de programación para automatizar tareas: backups, despliegues, mantenimiento, pegamento entre herramientas. Un script es un archivo de texto con comandos que se ejecutan en orden, con variables, condiciones, bucles y funciones.

## Índice

1. [Tu primer script y cómo ejecutarlo](#1-tu-primer-script-y-cómo-ejecutarlo)
2. [Variables y comillas](#2-variables-y-comillas)
3. [Argumentos y entrada de datos](#3-argumentos-y-entrada-de-datos)
4. [Condicionales](#4-condicionales)
5. [Bucles](#5-bucles)
6. [Funciones](#6-funciones)
7. [Códigos de salida y modo estricto](#7-códigos-de-salida-y-modo-estricto)
8. [Manipulación de strings](#8-manipulación-de-strings)
9. [Arrays](#9-arrays)
10. [Sustitución de comandos y archivos temporales](#10-sustitución-de-comandos-y-archivos-temporales)
11. [Trap y limpieza](#11-trap-y-limpieza)
12. [Validación y depuración](#12-validación-y-depuración)
13. [Ejemplo completo de la herramienta](#-ejemplo-completo-de-la-herramienta)
14. [Para después](#️-para-después)

**Cheatsheets relacionados:** `linux.md`, `grep-sed-awk.md`, `jq.md`, `cron.md`, `make.md`.

**Regla de oro:** si tu script supera ~100-150 líneas, tiene lógica compleja o maneja estructuras de datos pesadas, probablemente es hora de usar Python o Go. Bash brilla como pegamento entre comandos.

---

## 1. Tu primer script y cómo ejecutarlo

**Concepto:** un script es un archivo con una primera línea llamada *shebang* que indica qué intérprete lo ejecuta. Necesita permiso de ejecución.

| Elemento | Qué hace |
|---|---|
| `#!/usr/bin/env bash` | Shebang portable: busca `bash` en el PATH |
| `chmod +x script.sh` | Da permiso de ejecución |
| `./script.sh` | Ejecuta el script |
| `bash script.sh` | Ejecuta sin necesitar permiso de ejecución |
| `source script.sh` o `. script.sh` | Ejecuta en la shell actual (para cargar variables/funciones) |
| `# comentario` | Comentario |

**Ejemplo:**

```bash
#!/usr/bin/env bash
echo "Hola, $USER"
```

```bash
chmod +x hola.sh
./hola.sh
```

<details>
<summary>🏭 Ejemplo completo: esqueleto base de cualquier script</summary>

```bash
#!/usr/bin/env bash
#
# nombre-del-script.sh - Descripción en una línea de qué hace.
#
# Uso: ./nombre-del-script.sh [opciones] <argumento>

set -euo pipefail   # modo estricto (se explica en la sección 7)

main() {
  echo "Hola desde main"
}

main "$@"
```

Poner la lógica dentro de `main` y llamarla al final hace el script ordenado y más fácil de probar. `"$@"` le pasa todos los argumentos.

</details>

---

## 2. Variables y comillas

**Concepto:** las variables guardan valores. **Las comillas importan mucho**: son la fuente número uno de bugs en Bash.

| Sintaxis | Qué hace |
|---|---|
| `nombre="Ana"` | Asigna (**sin espacios** alrededor del `=`) |
| `"$nombre"` | Usa el valor (siempre entre comillas dobles) |
| `"${nombre}_v2"` | Llaves para delimitar el nombre |
| `"${VAR:-default}"` | Usa `default` si `VAR` está vacía o no definida |
| `"${VAR:?mensaje}"` | Aborta con mensaje si `VAR` no está definida |
| `readonly VAR="x"` | Constante |
| `export VAR="x"` | Disponible para procesos hijos |
| `local var="x"` | Variable local dentro de una función |

**Tipos de comillas:**

| Comillas | Comportamiento |
|---|---|
| `"doble"` | Expande variables (`$var`) y comandos (`$(cmd)`) |
| `'simple'` | Todo literal, nada se expande |
| sin comillas | ⚠️ Se parte en palabras y expande comodines |

**Variables especiales:**

| Variable | Significado |
|---|---|
| `$0` | Nombre del script |
| `$1`, `$2`... | Argumentos posicionales |
| `$#` | Cantidad de argumentos |
| `"$@"` | Todos los argumentos, cada uno como palabra separada |
| `$?` | Código de salida del último comando |
| `$$` | PID del script |

**Ejemplo:**

```bash
nombre="Mi Proyecto"
echo "$nombre"          # correcto
echo $nombre            # incorrecto: parte en dos palabras
puerto="${PORT:-8080}"
```

<details>
<summary>🏭 Ejemplo completo: el bug clásico de las comillas</summary>

```bash
archivo="mi reporte.txt"

# ❌ MAL: Bash ve dos argumentos: "mi" y "reporte.txt"
rm $archivo

# ✅ BIEN: un solo argumento
rm "$archivo"

# ✅ Valores por defecto y variables obligatorias
ENTORNO="${ENTORNO:-desarrollo}"
: "${DATABASE_URL:?Falta DATABASE_URL}"   # aborta si no existe

# ✅ Constantes al inicio del script
readonly BACKUP_DIR="/var/backups/app"
readonly FECHA="$(date +%F)"
```

**Hábito:** pon *siempre* `"$variable"` entre comillas dobles, salvo que tengas una razón concreta para no hacerlo. ShellCheck (sección 12) te avisa cuando se te olvida.

</details>

---

## 3. Argumentos y entrada de datos

**Concepto:** un script se vuelve reutilizable cuando recibe datos de fuera: argumentos, opciones, entrada del usuario o variables de entorno.

| Sintaxis | Qué hace |
|---|---|
| `$1`, `$2` | Primer y segundo argumento |
| `shift` | Descarta `$1` y corre los demás |
| `read -p "Texto: " var` | Pide un dato al usuario |
| `read -rsp "Clave: " var` | Pide un dato sin mostrarlo (contraseñas) |
| `getopts` | Procesa opciones tipo `-f valor` |
| `while read -r linea; do ...; done < archivo` | Lee un archivo línea por línea |

**Ejemplo:**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <nombre>" >&2
  exit 1
fi

echo "Hola, $1"
```

<details>
<summary>🏭 Ejemplo completo: opciones con getopts y confirmación</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Uso: $0 [-e entorno] [-v] <servicio>

  -e  Entorno destino (default: staging)
  -v  Modo verbose
  -h  Muestra esta ayuda
EOF
}

ENTORNO="staging"
VERBOSE=false

while getopts ":e:vh" opt; do
  case "$opt" in
    e) ENTORNO="$OPTARG" ;;
    v) VERBOSE=true ;;
    h) usage; exit 0 ;;
    \?) echo "Opción inválida: -$OPTARG" >&2; usage; exit 1 ;;
    :)  echo "La opción -$OPTARG requiere un valor" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))    # lo que queda son los argumentos posicionales

[[ $# -ge 1 ]] || { usage; exit 1; }
SERVICIO="$1"

# Confirmación antes de una acción delicada
if [[ "$ENTORNO" == "production" ]]; then
  read -rp "¿Desplegar $SERVICIO en PRODUCCIÓN? (escribe 'si'): " respuesta
  [[ "$respuesta" == "si" ]] || { echo "Cancelado."; exit 1; }
fi

$VERBOSE && echo "Desplegando $SERVICIO en $ENTORNO..."
```

Ejecución: `./deploy.sh -e production -v api`

</details>

---

## 4. Condicionales

**Concepto:** ejecutar código según se cumpla una condición. En Bash moderno usa `[[ ... ]]` (más seguro que `[ ... ]`).

| Sintaxis | Qué hace |
|---|---|
| `if [[ cond ]]; then ... fi` | Condicional simple |
| `elif` / `else` | Alternativas |
| `case $var in ... esac` | Múltiples opciones |
| `&&` / `\|\|` | Ejecuta el siguiente si el anterior tuvo éxito / falló |

**Pruebas de archivos:**

| Prueba | Verdadera si... |
|---|---|
| `-f archivo` | Existe y es archivo regular |
| `-d ruta` | Existe y es directorio |
| `-e ruta` | Existe (cualquier tipo) |
| `-r` / `-w` / `-x` | Se puede leer / escribir / ejecutar |
| `-s archivo` | Existe y no está vacío |

**Pruebas de texto y números:**

| Prueba | Verdadera si... |
|---|---|
| `-z "$v"` / `-n "$v"` | Vacío / no vacío |
| `"$a" == "$b"` | Strings iguales |
| `"$a" != "$b"` | Strings distintos |
| `"$a" =~ regex` | Coincide con expresión regular |
| `$a -eq $b` | Números iguales |
| `-ne`, `-lt`, `-le`, `-gt`, `-ge` | ≠, <, ≤, >, ≥ |
| `(( a > b ))` | Comparación aritmética alternativa |

**Ejemplo:**

```bash
if [[ -f "$archivo" ]]; then
  echo "Existe"
elif [[ -d "$archivo" ]]; then
  echo "Es un directorio"
else
  echo "No existe"
fi
```

<details>
<summary>🏭 Ejemplo completo: validaciones y case</summary>

```bash
# Comprobar que un comando existe antes de usarlo
if ! command -v docker &>/dev/null; then
  echo "Error: docker no está instalado" >&2
  exit 1
fi

# Comprobar que somos root
if [[ $EUID -ne 0 ]]; then
  echo "Este script requiere sudo" >&2
  exit 1
fi

# Validar que un argumento es un número
if ! [[ "$1" =~ ^[0-9]+$ ]]; then
  echo "El puerto debe ser numérico" >&2
  exit 1
fi

# case para subcomandos (patrón muy común)
case "${1:-}" in
  start)   echo "Iniciando..." ;;
  stop)    echo "Deteniendo..." ;;
  restart) echo "Reiniciando..." ;;
  status|st) echo "Estado..." ;;
  *)       echo "Uso: $0 {start|stop|restart|status}" >&2; exit 1 ;;
esac

# Atajos cortos
[[ -d "$DIR" ]] || mkdir -p "$DIR"        # crea si no existe
[[ -f .env ]] && source .env              # carga si existe
```

</details>

---

## 5. Bucles

**Concepto:** repetir acciones sobre una lista de elementos o mientras se cumpla una condición.

| Sintaxis | Qué hace |
|---|---|
| `for x in a b c; do ...; done` | Recorre una lista |
| `for f in *.log; do ...; done` | Recorre archivos |
| `for ((i=0; i<5; i++)); do ...; done` | Bucle estilo C |
| `for i in {1..10}` | Rango numérico |
| `while [[ cond ]]; do ...; done` | Mientras sea verdadera |
| `while read -r l; do ...; done < archivo` | Línea por línea |
| `break` / `continue` | Sale del bucle / salta a la siguiente vuelta |

**Ejemplo:**

```bash
for servidor in web1 web2 web3; do
  echo "Revisando $servidor"
done

for archivo in /var/log/*.log; do
  echo "$archivo: $(wc -l < "$archivo") líneas"
done
```

<details>
<summary>🏭 Ejemplo completo: reintentos y lectura de archivos</summary>

```bash
# Leer un archivo línea por línea (la forma correcta)
while IFS= read -r linea; do
  echo "Procesando: $linea"
done < servidores.txt

# Reintentar un comando hasta 5 veces (muy común al esperar un servicio)
intentos=0
max=5
until curl -fsS http://localhost:8080/health >/dev/null; do
  intentos=$((intentos + 1))
  if (( intentos >= max )); then
    echo "El servicio no respondió tras $max intentos" >&2
    exit 1
  fi
  echo "Intento $intentos/$max... esperando 3s"
  sleep 3
done
echo "Servicio arriba ✅"

# Ejecutar algo en varios servidores
for host in $(cat servidores.txt); do
  ssh "$host" 'uptime' || echo "Falló en $host" >&2
done
```

`IFS=` y `-r` en `read` evitan que Bash recorte espacios o interprete las barras invertidas.

</details>

---

## 6. Funciones

**Concepto:** bloques de código reutilizables con nombre. Hacen el script legible y evitan repetir.

| Sintaxis | Qué hace |
|---|---|
| `nombre() { ...; }` | Define una función |
| `nombre arg1 arg2` | La llama (sin paréntesis) |
| `$1`, `$2`, `$@` | Argumentos **de la función** |
| `local var` | Variable local (evita pisar globales) |
| `return N` | Devuelve un código de salida (0-255) |
| `echo "valor"` + `$(funcion)` | Devuelve un *valor* capturando su salida |

**Ejemplo:**

```bash
saludar() {
  local nombre="$1"
  echo "Hola, $nombre"
}

saludar "Ana"
mensaje="$(saludar "Luis")"
```

<details>
<summary>🏭 Ejemplo completo: funciones de logging y utilidades reutilizables</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

# --- Logging con timestamp, a stderr (no mezcla con la salida del script) ---
log()   { echo "[$(date +'%F %T')] [INFO]  $*" >&2; }
warn()  { echo "[$(date +'%F %T')] [WARN]  $*" >&2; }
error() { echo "[$(date +'%F %T')] [ERROR] $*" >&2; }
die()   { error "$*"; exit 1; }

# --- Verificar dependencias ---
require() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || die "Falta el comando: $cmd"
  done
}

# --- Función que devuelve un valor ---
get_version() {
  git describe --tags --always 2>/dev/null || echo "dev"
}

# --- Uso ---
require git docker curl
version="$(get_version)"
log "Construyendo versión $version"
```

Los logs van a **stderr** (`>&2`) para que la salida estándar quede limpia y se pueda usar en pipes o `$(...)`.

</details>

---

## 7. Códigos de salida y modo estricto

**Concepto:** todo comando devuelve un número: `0` significa éxito, cualquier otro significa error. Bash por defecto **ignora errores y sigue ejecutando**; el modo estricto lo evita.

| Sintaxis | Qué hace |
|---|---|
| `set -e` | Aborta si un comando falla |
| `set -u` | Aborta si usas una variable no definida |
| `set -o pipefail` | Un pipe falla si **cualquier** parte falla |
| `set -euo pipefail` | Los tres juntos (**úsalo siempre**) |
| `$?` | Código del último comando |
| `exit N` | Termina el script con código N |
| `cmd \|\| true` | Ignora un fallo esperado |
| `if cmd; then ...` | Usa el éxito/fallo directamente |

**Códigos convencionales:**

| Código | Significado |
|---|---|
| `0` | Éxito |
| `1` | Error general |
| `2` | Uso incorrecto |
| `126` / `127` | No ejecutable / comando no encontrado |
| `130` | Interrumpido con Ctrl+C |

**Ejemplo:**

```bash
#!/usr/bin/env bash
set -euo pipefail

cd /directorio/que/no/existe   # el script aborta aquí
echo "Esto nunca se ejecuta"
```

<details>
<summary>🏭 Ejemplo completo: por qué cada flag importa y sus trampas</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

# --- set -u: detecta typos en variables ---
rm -rf "$DIRECTORIO_BACKUP/"      # sin -u, si la variable está vacía esto sería: rm -rf /
                                  # con -u, el script aborta. Salva vidas.

# --- set -o pipefail: no esconde fallos en pipes ---
# Sin pipefail, el pipe devuelve el código del ÚLTIMO comando (wc), no el de grep
cat archivo-inexistente | wc -l   # con pipefail: falla como debe

# --- Trampa de set -e: grep sin coincidencias devuelve 1 ---
# ❌ Esto aborta el script si no hay coincidencias:
conteo=$(grep -c "ERROR" app.log)
# ✅ Maneja el caso esperado:
conteo=$(grep -c "ERROR" app.log || true)

# --- Usar el código de salida en un if (no aborta con set -e) ---
if grep -q "ERROR" app.log; then
  echo "Hay errores en el log"
fi

# --- Capturar el código de salida sin abortar ---
if ! systemctl is-active --quiet nginx; then
  echo "nginx está caído" >&2
  exit 3
fi
```

`set -e` tiene casos raros (funciones dentro de `if`, listas con `&&`), así que **no es una red de seguridad perfecta**: complétalo con validaciones explícitas en los puntos críticos.

</details>

---

## 8. Manipulación de strings

**Concepto:** Bash puede cortar, reemplazar y transformar texto sin llamar a programas externos, usando *parameter expansion*.

| Sintaxis | Qué hace | Ejemplo con `f="backup.tar.gz"` |
|---|---|---|
| `${#var}` | Longitud | `13` |
| `${var:0:6}` | Subcadena (inicio:largo) | `backup` |
| `${var%.gz}` | Quita sufijo (el más corto) | `backup.tar` |
| `${var%%.*}` | Quita sufijo (el más largo) | `backup` |
| `${var#*.}` | Quita prefijo (el más corto) | `tar.gz` |
| `${var##*.}` | Quita prefijo (el más largo) | `gz` |
| `${var/a/b}` | Reemplaza la primera | `bbckup.tar.gz` |
| `${var//a/b}` | Reemplaza todas | |
| `${var^^}` / `${var,,}` | Mayúsculas / minúsculas | |
| `$(basename "$ruta")` | Nombre del archivo de una ruta | |
| `$(dirname "$ruta")` | Directorio de una ruta | |

**Memoria rápida:** `#` quita desde el inicio (la `#` está a la izquierda en el teclado), `%` quita desde el final.

**Ejemplo:**

```bash
ruta="/var/log/nginx/access.log"
echo "${ruta##*/}"     # access.log   (como basename)
echo "${ruta%/*}"      # /var/log/nginx (como dirname)
echo "${ruta%.log}"    # /var/log/nginx/access
```

<details>
<summary>🏭 Ejemplo completo: renombrar archivos en lote</summary>

```bash
# Cambiar extensión .jpeg -> .jpg en todos los archivos
for f in *.jpeg; do
  mv -- "$f" "${f%.jpeg}.jpg"
done

# Agregar fecha al nombre de un backup
for f in *.sql; do
  mv -- "$f" "${f%.sql}-$(date +%F).sql"
done

# Convertir nombres a minúsculas y sin espacios
for f in *\ *; do
  nuevo="${f,,}"            # minúsculas
  nuevo="${nuevo// /-}"     # espacios -> guiones
  mv -- "$f" "$nuevo"
done

# Extraer el entorno del nombre de una rama (feat/login -> feat)
rama="feat/login"
tipo="${rama%%/*}"
```

`--` antes del nombre protege contra archivos que empiezan con `-`.

</details>

---

## 9. Arrays

**Concepto:** listas de valores. Útiles para guardar varios elementos sin ambigüedad con espacios. También existen arrays asociativos (diccionarios).

| Sintaxis | Qué hace |
|---|---|
| `arr=(a b c)` | Crea un array |
| `"${arr[0]}"` | Un elemento |
| `"${arr[@]}"` | Todos los elementos (**con comillas**) |
| `${#arr[@]}` | Cantidad de elementos |
| `arr+=("d")` | Agrega un elemento |
| `declare -A mapa` | Array asociativo (Bash 4+) |
| `mapa[clave]="valor"` | Asigna en el diccionario |
| `"${!mapa[@]}"` | Todas las claves |

**Ejemplo:**

```bash
servidores=("web1" "web2" "db1")

for s in "${servidores[@]}"; do
  echo "Revisando $s"
done
echo "Total: ${#servidores[@]}"
```

<details>
<summary>🏭 Ejemplo completo: lista de servicios y diccionario de puertos</summary>

```bash
# Revisar el estado de varios servicios
servicios=(nginx postgresql redis-server)

for svc in "${servicios[@]}"; do
  if systemctl is-active --quiet "$svc"; then
    echo "✅ $svc activo"
  else
    echo "❌ $svc caído"
  fi
done

# Diccionario: servicio -> puerto
declare -A puertos=(
  [nginx]=80
  [postgresql]=5432
  [redis-server]=6379
)

for svc in "${!puertos[@]}"; do
  if nc -z localhost "${puertos[$svc]}" 2>/dev/null; then
    echo "✅ $svc responde en el puerto ${puertos[$svc]}"
  else
    echo "❌ $svc no responde en ${puertos[$svc]}"
  fi
done

# Construir un comando con argumentos opcionales de forma segura
args=(--rm -it)
[[ -n "${ENV_FILE:-}" ]] && args+=(--env-file "$ENV_FILE")
docker run "${args[@]}" mi-imagen
```

Los arrays son la forma correcta de armar comandos con argumentos variables (en lugar de concatenar strings).

</details>

---

## 10. Sustitución de comandos y archivos temporales

**Concepto:** capturar la salida de un comando en una variable, y crear archivos temporales de forma segura.

| Sintaxis | Qué hace |
|---|---|
| `$(comando)` | Sustituye por la salida del comando |
| `$((a + b))` | Aritmética |
| `<(comando)` | Trata la salida de un comando como un archivo |
| `mktemp` | Crea un archivo temporal único y seguro |
| `mktemp -d` | Crea un directorio temporal |
| `<<EOF ... EOF` | Here-document: bloque de texto multilínea |
| `<<'EOF' ... EOF` | Here-document sin expandir variables |
| `date +%F` | Fecha `2026-11-25` |
| `date +%F_%H-%M-%S` | Fecha y hora para nombres de archivo |

**Ejemplo:**

```bash
fecha="$(date +%F)"
archivos="$(ls | wc -l)"
total=$((archivos * 2))
echo "Hoy es $fecha, hay $archivos archivos"
```

<details>
<summary>🏭 Ejemplo completo: temporales seguros y here-documents</summary>

```bash
# Directorio temporal único (no uses /tmp/miarchivo: es predecible e inseguro)
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT      # se borra solo al terminar (ver sección 11)

curl -fsSL https://ejemplo.com/datos.json -o "$tmpdir/datos.json"
jq '.items | length' "$tmpdir/datos.json"

# Generar un archivo de configuración con variables expandidas
cat > /tmp/app.conf <<EOF
entorno=$ENTORNO
puerto=$PUERTO
generado=$(date -Iseconds)
EOF

# Here-doc literal (sin expandir): ideal para scripts o configs con $
cat > /etc/cron.d/backup <<'EOF'
0 3 * * * root /opt/scripts/backup.sh
EOF

# Comparar dos salidas sin archivos intermedios
diff <(ls dir1) <(ls dir2)
```

</details>

---

## 11. Trap y limpieza

**Concepto:** `trap` ejecuta código cuando el script termina o recibe una señal. Garantiza la limpieza aunque haya un error o el usuario presione Ctrl+C.

| Sintaxis | Qué hace |
|---|---|
| `trap 'comando' EXIT` | Se ejecuta **siempre** al terminar |
| `trap 'comando' ERR` | Se ejecuta cuando un comando falla |
| `trap 'comando' INT TERM` | Se ejecuta con Ctrl+C o `kill` |
| `trap - EXIT` | Quita el trap |

**Ejemplo:**

```bash
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
```

<details>
<summary>🏭 Ejemplo completo: limpieza, lock y mensaje de error con línea</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly LOCKFILE="/tmp/mi-script.lock"
tmpdir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmpdir"
  rm -f "$LOCKFILE"
}
trap cleanup EXIT

# Informa en qué línea falló
on_error() {
  echo "Error en la línea $1 (código $2)" >&2
}
trap 'on_error $LINENO $?' ERR

# Evita ejecuciones simultáneas del mismo script (útil con cron)
if [[ -e "$LOCKFILE" ]]; then
  echo "Ya hay otra instancia ejecutándose" >&2
  exit 1
fi
touch "$LOCKFILE"

# ...trabajo real con $tmpdir...
```

Alternativa más robusta para el lock: `flock` (`exec 200>/tmp/x.lock; flock -n 200 || exit 1`).

</details>

---

## 12. Validación y depuración

**Concepto:** herramientas para encontrar errores antes y durante la ejecución.

| Comando | Qué hace |
|---|---|
| `shellcheck script.sh` | Análisis estático: detecta bugs y malas prácticas |
| `bash -n script.sh` | Revisa la sintaxis sin ejecutar |
| `bash -x script.sh` | Ejecuta mostrando cada comando |
| `set -x` / `set +x` | Activa / desactiva el modo traza dentro del script |
| `PS4='+ ${LINENO}: '` | Muestra el número de línea en la traza |
| `shfmt -w script.sh` | Formatea el código |

Instalar: `sudo apt install shellcheck shfmt`

**Ejemplo:**

```bash
shellcheck deploy.sh
bash -x deploy.sh
```

<details>
<summary>🏭 Ejemplo completo: flujo de calidad antes de dar un script por bueno</summary>

```bash
# 1. Sintaxis
bash -n deploy.sh

# 2. Análisis estático (corrige TODO lo que reporte, vale la pena)
shellcheck deploy.sh

# 3. Prueba con traza detallada y líneas numeradas
PS4='+ ${BASH_SOURCE}:${LINENO}: ' bash -x deploy.sh

# 4. Traza solo de una zona sospechosa
set -x
comando_dudoso
set +x

# 5. Formato consistente
shfmt -i 2 -w deploy.sh

# 6. Modo simulación (patrón útil en scripts destructivos)
DRY_RUN="${DRY_RUN:-false}"
run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}
run rm -rf /ruta/vieja
# Prueba: DRY_RUN=true ./deploy.sh
```

También puedes ignorar una advertencia justificada con `# shellcheck disable=SC2086`, pero **explica por qué** en un comentario.

</details>

---

## 🏭 Ejemplo completo de la herramienta

<details>
<summary>Script de backup de PostgreSQL con todas las buenas prácticas</summary>

```bash
#!/usr/bin/env bash
#
# backup-db.sh - Respalda una base PostgreSQL, comprime y rota backups antiguos.
#
# Uso:    ./backup-db.sh [-r días] [-n] <nombre_db>
# Ejemplo: ./backup-db.sh -r 14 mi_api
# Cron:   0 3 * * * /opt/scripts/backup-db.sh mi_api >> /var/log/backup-db.log 2>&1

set -euo pipefail

# ── Configuración ───────────────────────────────────────────
readonly BACKUP_DIR="${BACKUP_DIR:-/var/backups/postgres}"
readonly LOCKFILE="/tmp/backup-db.lock"
RETENCION_DIAS=7
DRY_RUN=false

# ── Utilidades ──────────────────────────────────────────────
log()   { echo "[$(date +'%F %T')] [INFO]  $*" >&2; }
error() { echo "[$(date +'%F %T')] [ERROR] $*" >&2; }
die()   { error "$*"; exit 1; }

usage() {
  cat <<EOF
Uso: $0 [-r días] [-n] <nombre_db>

  -r  Días de retención de backups (default: $RETENCION_DIAS)
  -n  Modo simulación (no borra nada)
  -h  Ayuda
EOF
}

require() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || die "Falta el comando: $cmd"
  done
}

cleanup() {
  rm -f "$LOCKFILE"
}
trap cleanup EXIT
trap 'error "Falló en la línea $LINENO"' ERR

# ── Argumentos ──────────────────────────────────────────────
while getopts ":r:nh" opt; do
  case "$opt" in
    r) RETENCION_DIAS="$OPTARG" ;;
    n) DRY_RUN=true ;;
    h) usage; exit 0 ;;
    \?) error "Opción inválida: -$OPTARG"; usage; exit 1 ;;
    :)  error "La opción -$OPTARG requiere un valor"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

[[ $# -eq 1 ]] || { usage; exit 1; }
readonly DB_NAME="$1"
[[ "$RETENCION_DIAS" =~ ^[0-9]+$ ]] || die "La retención debe ser un número"

# ── Lógica principal ────────────────────────────────────────
main() {
  require pg_dump gzip find

  # Evita ejecuciones simultáneas
  [[ ! -e "$LOCKFILE" ]] || die "Ya hay un backup en curso"
  touch "$LOCKFILE"

  mkdir -p "$BACKUP_DIR"
  local archivo="$BACKUP_DIR/${DB_NAME}_$(date +%F_%H-%M-%S).sql.gz"

  log "Respaldando '$DB_NAME' en $archivo"
  pg_dump "$DB_NAME" | gzip > "$archivo"

  # Verifica que el archivo existe y no está vacío
  [[ -s "$archivo" ]] || die "El backup quedó vacío"
  gzip -t "$archivo"  || die "El backup está corrupto"
  chmod 600 "$archivo"
  log "Backup OK ($(du -h "$archivo" | cut -f1))"

  # Rotación: borra backups más viejos que la retención
  log "Eliminando backups con más de $RETENCION_DIAS días"
  if [[ "$DRY_RUN" == "true" ]]; then
    find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -mtime +"$RETENCION_DIAS" -print
  else
    find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -mtime +"$RETENCION_DIAS" -delete
  fi

  log "Terminado"
}

main
```

**Qué practica este script:** shebang portable, `set -euo pipefail`, constantes con `readonly`, funciones de log a stderr, `trap` para limpieza y errores con número de línea, `getopts`, validación de entradas, verificación de dependencias, lock contra ejecuciones simultáneas, comprobación de integridad del resultado, permisos restrictivos (`600`), modo `dry-run` y comillas en todas las variables.

**Para programarlo con cron:**

```bash
crontab -e
0 3 * * * /opt/scripts/backup-db.sh mi_api >> /var/log/backup-db.log 2>&1
```

</details>

---

## ⏭️ Para después

Existe, es útil, pero no lo necesitas hoy:

- Redirecciones avanzadas: `exec`, descriptores de archivo, `coproc`
- Procesamiento paralelo: `xargs -P`, `GNU parallel`, `wait`
- `select` para menús interactivos, `dialog`/`whiptail`
- Expresiones regulares avanzadas con `=~` y `BASH_REMATCH`
- Testing de scripts con `bats-core`
- `flock` para bloqueos robustos
- `printf` con formatos avanzados
- Portabilidad POSIX (`sh`, `dash`) frente a Bash
- Bibliotecas de funciones compartidas con `source`
- `envsubst`, `getopt` (versión GNU, distinta de `getopts`)

---

## Referencias

- ShellCheck (explica cada error): <https://www.shellcheck.net>
- Bash Reference Manual: <https://www.gnu.org/software/bash/manual/>
- Guía de estilo de Google para Shell: <https://google.github.io/styleguide/shellguide.html>
- Bash Pitfalls (errores comunes): <https://mywiki.wooledge.org/BashPitfalls>
- explainshell: <https://explainshell.com>