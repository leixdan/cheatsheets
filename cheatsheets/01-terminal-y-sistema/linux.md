# Linux

> Sistema operativo base de casi todos los servidores y contenedores. Aquí está lo esencial de la línea de comandos en **Debian/Ubuntu**: moverte, manejar archivos, permisos, procesos, disco y red.

## Índice

1. [Estructura de directorios](#1-estructura-de-directorios)
2. [Navegación y archivos](#2-navegación-y-archivos)
3. [Ver y buscar contenido](#3-ver-y-buscar-contenido)
4. [Redirecciones y pipes](#4-redirecciones-y-pipes)
5. [Permisos y propietarios](#5-permisos-y-propietarios)
6. [Usuarios, grupos y sudo](#6-usuarios-grupos-y-sudo)
7. [Procesos](#7-procesos)
8. [Disco y almacenamiento](#8-disco-y-almacenamiento)
9. [Red básica](#9-red-básica)
10. [Variables de entorno y PATH](#10-variables-de-entorno-y-path)
11. [Comprimir y archivar](#11-comprimir-y-archivar)
12. [Información del sistema](#12-información-del-sistema)
13. [Ejemplo completo de la herramienta](#-ejemplo-completo-de-la-herramienta)
14. [Para después](#️-para-después)

**Cheatsheets relacionados:** `bash-scripting.md`, `systemd.md`, `apt-dpkg.md`, `ssh.md`, `grep-sed-awk.md`, `logs-journalctl.md`.

**Atajos de terminal que te ahorran mucho:**

| Atajo | Qué hace |
|---|---|
| `Tab` | Autocompleta comandos y rutas |
| `↑` / `Ctrl+R` | Historial / búsqueda en el historial |
| `Ctrl+C` | Cancela el comando en curso |
| `Ctrl+D` | Cierra sesión / fin de entrada |
| `Ctrl+L` | Limpia la pantalla |
| `Ctrl+A` / `Ctrl+E` | Inicio / final de la línea |
| `Ctrl+W` | Borra la palabra anterior |
| `!!` | Repite el último comando (útil: `sudo !!`) |

**Ayuda sin salir de la terminal:**

```bash
man comando            # manual completo (q para salir)
comando --help         # resumen rápido
tldr comando           # ejemplos prácticos (sudo apt install tldr)
```

---

## 1. Estructura de directorios

**Concepto:** en Linux todo cuelga de `/` (raíz). Saber qué vive en cada carpeta te dice dónde buscar configuraciones, logs y programas.

| Ruta | Contenido |
|---|---|
| `/home/usuario` | Tus archivos personales (`~`) |
| `/etc` | Archivos de configuración del sistema |
| `/var/log` | Logs |
| `/var/lib` | Datos de servicios (bases de datos, Docker) |
| `/usr/bin`, `/usr/local/bin` | Programas instalados |
| `/opt` | Software de terceros |
| `/tmp` | Temporales (se borran al reiniciar) |
| `/dev` | Dispositivos (discos, terminales) |
| `/proc`, `/sys` | Información del kernel en tiempo real |
| `/root` | Home del usuario root |

**Ejemplo:**

```bash
ls /etc/nginx          # configuración de nginx
ls /var/log            # logs del sistema
```

<details>
<summary>🏭 Ejemplo completo: ¿dónde está cada cosa de un servicio?</summary>

```bash
# Para un servicio como nginx, la regla general es:
ls /etc/nginx/                  # configuración
ls /var/log/nginx/              # logs
ls /usr/share/nginx/html/       # archivos estáticos por defecto
which nginx                     # ruta del binario  -> /usr/sbin/nginx
dpkg -L nginx | head -20        # todos los archivos que instaló el paquete
```

Regla: **configuración en `/etc`, logs en `/var/log`, datos en `/var/lib`**. Casi todos los servicios siguen este patrón.

</details>

---

## 2. Navegación y archivos

**Concepto:** moverte por el sistema de archivos y crear, copiar, mover y borrar.

| Comando | Qué hace |
|---|---|
| `pwd` | Muestra el directorio actual |
| `ls -lah` | Lista con detalle, ocultos y tamaños legibles |
| `cd ruta` | Cambia de directorio |
| `cd -` | Vuelve al directorio anterior |
| `cd` o `cd ~` | Va a tu home |
| `mkdir -p a/b/c` | Crea carpetas anidadas |
| `touch archivo` | Crea un archivo vacío (o actualiza su fecha) |
| `cp -r origen destino` | Copia (`-r` para carpetas) |
| `mv origen destino` | Mueve o renombra |
| `rm archivo` | Borra un archivo |
| `rm -r carpeta` | Borra una carpeta ⚠️ |
| `ln -s destino enlace` | Crea un enlace simbólico |
| `tree -L 2` | Muestra el árbol de directorios (2 niveles) |

> ⚠️ En Linux **no hay papelera**: `rm` borra para siempre. Nunca ejecutes `rm -rf` con rutas que no hayas verificado antes (y menos con `sudo`).

**Ejemplo:**

```bash
mkdir -p ~/proyectos/api/src
cd ~/proyectos/api
touch README.md
cp README.md README.bak
mv README.bak docs.md
```

<details>
<summary>🏭 Ejemplo completo: organizar un proyecto y borrar con seguridad</summary>

```bash
# Crear estructura de un proyecto
mkdir -p ~/proyectos/mi-api/{src,tests,docs,scripts}
cd ~/proyectos/mi-api
touch README.md .gitignore

# Verifica con ls ANTES de borrar con comodín
ls *.log
rm -i *.log                # -i pregunta archivo por archivo

# Borrar carpeta: primero mira qué hay dentro
ls -la carpeta-vieja/
rm -r carpeta-vieja/

# Enlace simbólico: típico para versiones de configuración
ln -s /etc/nginx/sites-available/mi-api /etc/nginx/sites-enabled/mi-api

# Copiar preservando permisos y fechas (backups)
cp -a configuracion/ configuracion.bak/
```

</details>

---

## 3. Ver y buscar contenido

**Concepto:** leer archivos sin abrir un editor y encontrar archivos o texto dentro de ellos.

| Comando | Qué hace |
|---|---|
| `cat archivo` | Muestra el archivo completo |
| `less archivo` | Lo muestra paginado (`/texto` busca, `q` sale) |
| `head -n 20 archivo` | Primeras 20 líneas |
| `tail -n 50 archivo` | Últimas 50 líneas |
| `tail -f archivo` | Sigue el archivo en tiempo real (logs) |
| `wc -l archivo` | Cuenta líneas |
| `grep "texto" archivo` | Busca texto en un archivo |
| `grep -rn "texto" carpeta/` | Busca recursivo con número de línea |
| `grep -i` / `grep -v` | Ignora mayúsculas / invierte (excluye) |
| `find ruta -name "*.log"` | Busca archivos por nombre |
| `find ruta -mtime -1` | Modificados en las últimas 24 h |
| `find ruta -size +100M` | Archivos mayores a 100 MB |
| `which comando` | Ruta de un ejecutable |

**Ejemplo:**

```bash
tail -f /var/log/syslog
grep -rn "TODO" src/
find / -name "nginx.conf" 2>/dev/null
```

<details>
<summary>🏭 Ejemplo completo: investigar un error en producción</summary>

```bash
# 1. Mira el final del log y síguelo en vivo
sudo tail -f /var/log/nginx/error.log

# 2. Busca errores de la última hora, ignorando mayúsculas
sudo grep -i "error" /var/log/myapp/app.log | tail -n 50

# 3. Cuántos errores hay por tipo
sudo grep -i "error" /var/log/myapp/app.log | sort | uniq -c | sort -rn | head

# 4. Encuentra archivos enormes que podrían estar llenando el disco
sudo find /var -type f -size +500M -exec ls -lh {} \; 2>/dev/null

# 5. Encuentra qué archivos de config cambiaron en los últimos 2 días
sudo find /etc -type f -mtime -2

# 6. Busca dónde se define una variable en todo el proyecto
grep -rn "DATABASE_URL" --include="*.py" --include="*.env*" .
```

`2>/dev/null` descarta los errores de "permiso denegado" para que el resultado sea legible.

</details>

---

## 4. Redirecciones y pipes

**Concepto:** cada comando tiene una salida normal (stdout), una de errores (stderr) y una entrada (stdin). Puedes redirigirlas a archivos o conectar comandos entre sí con `|`.

| Símbolo | Qué hace |
|---|---|
| `>` | Redirige la salida a un archivo (sobrescribe) |
| `>>` | Redirige agregando al final |
| `2>` | Redirige los errores |
| `2>&1` | Une errores con la salida normal |
| `&> archivo` | Salida y errores a un archivo (Bash) |
| `<` | Toma la entrada desde un archivo |
| `\|` | Pasa la salida de un comando como entrada del siguiente |
| `tee archivo` | Muestra en pantalla **y** guarda en archivo |
| `/dev/null` | "Agujero negro": descarta lo que le mandes |
| `xargs` | Convierte la entrada en argumentos de otro comando |

**Ejemplo:**

```bash
ls -la > listado.txt
comando 2> errores.log
cat access.log | grep "404" | wc -l
```

<details>
<summary>🏭 Ejemplo completo: pipeline para analizar un log</summary>

```bash
# Top 10 IPs que más peticiones hacen a nginx
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10

# Ejecutar y guardar el resultado viéndolo en pantalla a la vez
sudo apt update 2>&1 | tee ~/apt-update.log

# Escribir un archivo de configuración que requiere root
# (con "sudo echo > archivo" NO funciona: la redirección la hace tu usuario, no sudo)
echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-custom.conf

# Borrar todos los .tmp encontrados, de forma segura con espacios en nombres
find . -name "*.tmp" -print0 | xargs -0 rm -v

# Silenciar todo y solo usar el código de salida
if grep -q "ERROR" app.log &> /dev/null; then
  echo "Hay errores"
fi
```

</details>

---

## 5. Permisos y propietarios

**Concepto:** cada archivo tiene un dueño, un grupo y permisos de lectura (`r`), escritura (`w`) y ejecución (`x`) para: dueño, grupo y otros.

```
-rwxr-xr--   1  usuario  grupo  ...  script.sh
 │└┬┘└┬┘└┬┘
 │ │  │  └── otros:  r--  (4)
 │ │  └───── grupo:  r-x  (5)
 │ └──────── dueño:  rwx  (7)
 └────────── tipo: - archivo, d directorio, l enlace
```

| Número | Permiso |
|---|---|
| `7` | `rwx` (todo) |
| `6` | `rw-` (leer y escribir) |
| `5` | `r-x` (leer y ejecutar) |
| `4` | `r--` (solo leer) |
| `0` | `---` (nada) |

| Comando | Qué hace |
|---|---|
| `ls -l` | Muestra permisos y dueño |
| `chmod 755 archivo` | Permisos numéricos |
| `chmod +x script.sh` | Da permiso de ejecución |
| `chmod u+rw,g-w,o-rwx archivo` | Permisos simbólicos |
| `chmod -R 755 carpeta` | Recursivo |
| `chown usuario:grupo archivo` | Cambia dueño y grupo |
| `chown -R usuario:grupo carpeta` | Recursivo |

**Valores comunes:**

| Permiso | Uso típico |
|---|---|
| `644` | Archivos normales (`rw-r--r--`) |
| `755` | Directorios y scripts ejecutables |
| `600` | Archivos privados (llaves SSH, `.env`) |
| `700` | Directorios privados (`~/.ssh`) |

**Ejemplo:**

```bash
chmod +x deploy.sh
chmod 600 .env
sudo chown www-data:www-data /var/www/html
```

<details>
<summary>🏭 Ejemplo completo: asegurar archivos sensibles y directorio de aplicación</summary>

```bash
# Llaves SSH: ssh se niega a usarlas si los permisos son más abiertos
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Archivo con secretos: solo tu usuario puede leerlo
chmod 600 .env

# Directorio de una app web: dueño del servicio, nadie más escribe
sudo chown -R www-data:www-data /var/www/mi-app
sudo find /var/www/mi-app -type d -exec chmod 755 {} \;
sudo find /var/www/mi-app -type f -exec chmod 644 {} \;

# Script ejecutable
chmod 750 /opt/scripts/backup.sh
```

⚠️ **Nunca uses `chmod 777`**. Da permiso de escritura a cualquiera y es la "solución" que causa más problemas de seguridad. Si algo no funciona por permisos, averigua qué usuario lo ejecuta (`ps aux`) y ajusta el dueño.

</details>

---

## 6. Usuarios, grupos y sudo

**Concepto:** cada proceso corre como un usuario. Se trabaja con un usuario normal y se eleva a root con `sudo` solo cuando hace falta (principio de mínimo privilegio).

| Comando | Qué hace |
|---|---|
| `whoami` | Tu usuario actual |
| `id` | Tu UID, grupos y GID |
| `sudo comando` | Ejecuta como root |
| `sudo -i` | Shell interactiva de root (úsala con moderación) |
| `sudo adduser nombre` | Crea usuario (interactivo, recomendado en Debian) |
| `sudo usermod -aG grupo usuario` | Agrega usuario a un grupo (**`-a` es obligatorio**) |
| `sudo passwd usuario` | Cambia contraseña |
| `sudo deluser usuario` | Elimina usuario |
| `groups usuario` | Grupos de un usuario |
| `getent passwd` | Lista usuarios del sistema |
| `su - usuario` | Cambia de usuario |
| `sudo visudo` | Edita permisos de sudo de forma segura |

> ⚠️ `usermod -G` sin `-a` **reemplaza** todos los grupos del usuario en vez de agregar.

**Ejemplo:**

```bash
sudo adduser deploy
sudo usermod -aG sudo deploy
sudo usermod -aG docker $USER      # cerrar sesión y volver a entrar
```

<details>
<summary>🏭 Ejemplo completo: crear un usuario de despliegue con acceso SSH</summary>

```bash
# 1. Crear el usuario sin contraseña (se entra solo con llave SSH)
sudo adduser --disabled-password --gecos "" deploy

# 2. Darle acceso a docker
sudo usermod -aG docker deploy

# 3. Instalar tu llave pública
sudo mkdir -p /home/deploy/.ssh
echo "ssh-ed25519 AAAA... tu@correo.com" | sudo tee /home/deploy/.ssh/authorized_keys
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy/.ssh

# 4. Verificar
id deploy
ssh deploy@servidor
```

Este es el patrón estándar: nada de entrar como `root` ni con contraseñas. Más sobre esto en `ssh-hardening.md`.

</details>

---

## 7. Procesos

**Concepto:** un proceso es un programa en ejecución. Cada uno tiene un PID. Aprende a verlos, vigilarlos y detenerlos.

| Comando | Qué hace |
|---|---|
| `ps aux` | Lista todos los procesos |
| `ps aux \| grep nombre` | Busca un proceso |
| `top` / `htop` | Monitor en tiempo real (`q` sale) |
| `pgrep -a nombre` | Busca PIDs por nombre |
| `kill PID` | Pide al proceso que termine (SIGTERM) |
| `kill -9 PID` | Lo mata a la fuerza (SIGKILL) ⚠️ |
| `pkill nombre` | Termina por nombre |
| `comando &` | Ejecuta en segundo plano |
| `jobs` / `fg` / `bg` | Gestiona trabajos de la shell |
| `nohup comando &` | Sigue corriendo aunque cierres la terminal |
| `lsof -i :8080` | Qué proceso usa el puerto 8080 |
| `free -h` | Memoria usada y disponible |
| `uptime` | Tiempo encendido y carga |

**Señales:** primero `kill PID` (termina con orden); solo si no responde, `kill -9 PID`.

**Ejemplo:**

```bash
ps aux | grep nginx
lsof -i :3000          # ¿quién ocupa el puerto?
kill 4521
```

<details>
<summary>🏭 Ejemplo completo: "el puerto está ocupado" y "el servidor va lento"</summary>

```bash
# ── PUERTO OCUPADO ───────────────────────────────────────
sudo lsof -i :8080            # o: sudo ss -tulpn | grep 8080
# COMMAND  PID  USER ...
# node    4521  deploy
kill 4521                     # terminación ordenada
sleep 2
kill -0 4521 2>/dev/null && kill -9 4521   # solo si sigue vivo

# ── SERVIDOR LENTO ───────────────────────────────────────
uptime                        # ¿carga alta? (comparar con nº de CPUs: nproc)
free -h                       # ¿memoria o swap agotadas?
htop                          # ordena por CPU (F6) o memoria
ps aux --sort=-%mem | head -5 # top 5 procesos por memoria
df -h                         # ¿disco lleno?

# ── PROCESO LARGO SIN PERDERLO AL CERRAR SSH ─────────────
nohup ./proceso-largo.sh > salida.log 2>&1 &
# (mejor aún: usar tmux o un servicio systemd)
```

Para servicios de larga duración, no uses `nohup`: crea una unidad de systemd (ver `systemd.md`).

</details>

---

## 8. Disco y almacenamiento

**Concepto:** saber cuánto espacio queda y qué lo está ocupando. Un disco lleno es una de las causas más comunes de fallos en servidores.

| Comando | Qué hace |
|---|---|
| `df -h` | Espacio por partición |
| `du -sh carpeta` | Tamaño total de una carpeta |
| `du -h --max-depth=1 \| sort -hr` | Qué carpetas ocupan más |
| `lsblk` | Discos y particiones |
| `mount` / `findmnt` | Sistemas montados |
| `sudo mount /dev/sdb1 /mnt/datos` | Monta un disco |
| `sudo umount /mnt/datos` | Desmonta |
| `ncdu` | Explorador interactivo de uso de disco |
| `df -i` | Uso de inodos (puede llenarse con espacio libre) |

**Ejemplo:**

```bash
df -h
sudo du -h --max-depth=1 /var | sort -hr | head
```

<details>
<summary>🏭 Ejemplo completo: "se llenó el disco", diagnóstico paso a paso</summary>

```bash
# 1. ¿Qué partición está llena?
df -h
# /dev/sda1   50G   49G   1G   98%  /

# 2. Baja nivel por nivel hasta encontrar al culpable
sudo du -h --max-depth=1 / 2>/dev/null | sort -hr | head
sudo du -h --max-depth=1 /var 2>/dev/null | sort -hr | head
sudo du -h --max-depth=1 /var/log 2>/dev/null | sort -hr | head

# 3. Alternativa interactiva
sudo apt install ncdu && sudo ncdu /

# 4. Causas típicas y su limpieza
sudo journalctl --vacuum-size=200M     # logs del sistema
sudo apt clean && sudo apt autoremove  # caché de paquetes
docker system df                       # espacio usado por Docker
docker system prune -a                 # ⚠️ borra imágenes/contenedores sin usar

# 5. Si df dice libre pero no puedes crear archivos: inodos
df -i
```

Para evitar sorpresas, configura rotación de logs (`logrotate`) y alertas de disco (ver `prometheus-grafana.md`).

</details>

---

## 9. Red básica

**Concepto:** comandos para saber tu IP, probar conectividad, ver puertos abiertos y descargar cosas.

| Comando | Qué hace |
|---|---|
| `ip a` | Interfaces e IPs |
| `ip r` | Tabla de rutas (puerta de enlace) |
| `ping -c 4 host` | Prueba de conectividad |
| `ss -tulpn` | Puertos en escucha y qué proceso los usa |
| `curl -I https://sitio.com` | Solo las cabeceras HTTP |
| `curl -fsSL url` | Descarga silenciosa que falla si hay error |
| `wget url` | Descarga un archivo |
| `dig dominio` | Consulta DNS |
| `dig +short dominio` | Solo la respuesta |
| `nc -zv host 443` | ¿Está abierto el puerto? |
| `traceroute host` | Ruta hasta el destino |
| `hostname -I` | Tus IPs en una línea |
| `sudo ufw status` | Estado del firewall |

**Ejemplo:**

```bash
ip a
ss -tulpn
ping -c 3 8.8.8.8
dig +short google.com
```

<details>
<summary>🏭 Ejemplo completo: "no puedo conectarme al servicio", diagnóstico por capas</summary>

```bash
# CAPA 1: ¿Tengo red?
ip a                          # ¿tengo IP?
ip r                          # ¿hay gateway?
ping -c 2 8.8.8.8             # ¿salgo a internet por IP?

# CAPA 2: ¿Funciona el DNS?
ping -c 2 google.com          # si falla aquí pero pasó el anterior: es DNS
dig +short google.com

# CAPA 3: ¿El servicio escucha en el servidor?
sudo ss -tulpn | grep :8080
#  0.0.0.0:8080   -> accesible desde fuera
#  127.0.0.1:8080 -> SOLO accesible desde la propia máquina

# CAPA 4: ¿Alcanzo el puerto desde el cliente?
nc -zv servidor 8080
curl -v http://servidor:8080/health

# CAPA 5: ¿Lo bloquea un firewall?
sudo ufw status verbose
```

Ir por capas evita adivinar: sabes exactamente en qué punto falla. Más detalle en `dns-tcp-ip.md` y `ufw-nftables.md`.

</details>

---

## 10. Variables de entorno y PATH

**Concepto:** las variables de entorno configuran programas (rutas, credenciales, modo de ejecución). `PATH` es la lista de carpetas donde la shell busca ejecutables.

| Comando | Qué hace |
|---|---|
| `echo $VARIABLE` | Muestra el valor |
| `env` / `printenv` | Lista todas las variables |
| `export VAR=valor` | Define una variable para la sesión y sus hijos |
| `unset VAR` | Elimina una variable |
| `echo $PATH` | Muestra el PATH |
| `export PATH="$HOME/bin:$PATH"` | Agrega una carpeta al PATH |
| `source ~/.bashrc` | Recarga la configuración de la shell |
| `alias ll='ls -lah'` | Crea un atajo |

**Archivos de configuración de Bash:**

| Archivo | Cuándo se carga |
|---|---|
| `~/.bashrc` | Cada terminal interactiva (aquí van tus aliases) |
| `~/.profile` | Al iniciar sesión |
| `/etc/environment` | Variables globales del sistema |

**Ejemplo:**

```bash
export APP_ENV=production
echo $APP_ENV
echo 'alias ll="ls -lah"' >> ~/.bashrc && source ~/.bashrc
```

<details>
<summary>🏭 Ejemplo completo: cargar un .env y configurar tu shell</summary>

```bash
# Cargar todas las variables de un archivo .env en la sesión actual
set -a            # exporta automáticamente todo lo que se defina
source .env
set +a

# Ver que se cargó (¡sin imprimir secretos en logs compartidos!)
echo "$APP_ENV"

# ~/.bashrc recomendado
cat >> ~/.bashrc <<'EOF'
# Mi PATH personal
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Aliases
alias ll='ls -lah'
alias ..='cd ..'
alias gs='git status -sb'
alias dc='docker compose'

# Historial más útil
export HISTSIZE=10000
export HISTCONTROL=ignoredups:erasedups
EOF
source ~/.bashrc
```

Buenas prácticas: los secretos van en `.env` (con `chmod 600`, en `.gitignore`) o en un gestor de secretos, **nunca** escritos en el código ni en `~/.bashrc`.

</details>

---

## 11. Comprimir y archivar

**Concepto:** `tar` empaqueta carpetas en un solo archivo y, junto con `gzip`, las comprime. Es el formato estándar para backups y distribución.

| Comando | Qué hace |
|---|---|
| `tar -czvf archivo.tar.gz carpeta/` | **C**rea comprimido (gzip) |
| `tar -xzvf archivo.tar.gz` | E**x**trae |
| `tar -xzvf archivo.tar.gz -C /destino` | Extrae en otra carpeta |
| `tar -tzvf archivo.tar.gz` | Lista el contenido sin extraer |
| `zip -r archivo.zip carpeta/` | Crea un zip |
| `unzip archivo.zip` | Descomprime un zip |
| `gzip archivo` / `gunzip archivo.gz` | Comprime / descomprime un solo archivo |
| `scp archivo usuario@host:/ruta` | Copia por SSH |
| `rsync -avz origen/ destino/` | Sincroniza carpetas (eficiente) |

**Memoria rápida:** `c`reate, `x`tract, `z` gzip, `v`erbose, `f`ile (siempre al final, antes del nombre).

**Ejemplo:**

```bash
tar -czvf backup.tar.gz ~/proyectos/
tar -xzvf backup.tar.gz -C /tmp/
```

<details>
<summary>🏭 Ejemplo completo: backup con fecha y sincronización a un servidor</summary>

```bash
# Backup con fecha en el nombre
FECHA=$(date +%F)                        # 2026-11-25
tar -czf "backup-$FECHA.tar.gz" --exclude='node_modules' --exclude='.git' ~/proyectos/mi-api

# Verificar que no está corrupto
tar -tzf "backup-$FECHA.tar.gz" > /dev/null && echo "OK"

# Sincronizar al servidor
#  -a conserva permisos/fechas, -v detalle, -z comprime en tránsito
#  --delete borra en destino lo que ya no existe en origen (¡cuidado!)
#  Prueba SIEMPRE antes con --dry-run
rsync -avz --dry-run ~/proyectos/ usuario@servidor:/backups/proyectos/
rsync -avz ~/proyectos/ usuario@servidor:/backups/proyectos/

# Borrar backups de más de 30 días
find . -name "backup-*.tar.gz" -mtime +30 -delete
```

</details>

---

## 12. Información del sistema

**Concepto:** saber en qué máquina estás, qué versión corre y cuántos recursos tiene. Lo primero que haces al entrar a un servidor desconocido.

| Comando | Qué hace |
|---|---|
| `uname -a` | Kernel y arquitectura |
| `cat /etc/os-release` | Distribución y versión |
| `hostnamectl` | Nombre del host y SO |
| `lscpu` / `nproc` | CPU / número de núcleos |
| `free -h` | Memoria |
| `df -h` | Disco |
| `uptime` | Tiempo encendido y carga |
| `date` | Fecha y hora |
| `timedatectl` | Zona horaria y sincronización NTP |
| `last` | Últimos inicios de sesión |
| `history` | Historial de comandos |

**Ejemplo:**

```bash
cat /etc/os-release
uname -r
nproc && free -h && df -h
```

<details>
<summary>🏭 Ejemplo completo: reconocimiento de un servidor nuevo</summary>

```bash
# Pégalo al conectarte a un servidor que no conoces
echo "=== SO ===";       cat /etc/os-release | head -2
echo "=== KERNEL ===";   uname -r
echo "=== UPTIME ===";   uptime
echo "=== CPU ===";      nproc
echo "=== MEMORIA ===";  free -h
echo "=== DISCO ===";    df -h /
echo "=== USUARIO ===";  whoami
echo "=== PUERTOS ===";  sudo ss -tulpn | head -15
echo "=== SERVICIOS ==="; systemctl list-units --type=service --state=running | head -15
echo "=== ZONA HORARIA ==="; timedatectl | grep "Time zone"
```

Un buen candidato para convertir en un script de tu repo (ver `bash-scripting.md`).

</details>

---

## 🏭 Ejemplo completo de la herramienta

<details>
<summary>Flujo de principio a fin: preparar y diagnosticar un servidor Ubuntu/Debian</summary>

```bash
# ── 1. PRIMERA CONEXIÓN: reconocer el servidor ──────────
ssh usuario@servidor
cat /etc/os-release | head -2
uname -r && nproc && free -h && df -h /

# ── 2. ACTUALIZAR EL SISTEMA ────────────────────────────
sudo apt update && sudo apt upgrade -y

# ── 3. CREAR USUARIO NO-ROOT ────────────────────────────
sudo adduser --disabled-password --gecos "" deploy
sudo usermod -aG sudo deploy
sudo mkdir -p /home/deploy/.ssh
echo "ssh-ed25519 AAAA... tu@correo.com" | sudo tee /home/deploy/.ssh/authorized_keys
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy/.ssh

# ── 4. ESTRUCTURA DE LA APLICACIÓN ──────────────────────
sudo mkdir -p /opt/mi-api/{releases,shared,logs}
sudo chown -R deploy:deploy /opt/mi-api
chmod 750 /opt/mi-api

# ── 5. VARIABLES DE ENTORNO PRIVADAS ────────────────────
cat > /opt/mi-api/shared/.env <<'EOF'
APP_ENV=production
DATABASE_URL=postgres://usuario:clave@localhost:5432/mi_api
EOF
chmod 600 /opt/mi-api/shared/.env

# ── 6. DIAGNÓSTICO: algo va mal ─────────────────────────
uptime                                   # ¿carga alta?
free -h                                  # ¿memoria?
df -h                                    # ¿disco?
ps aux --sort=-%mem | head -5            # ¿quién consume?
sudo ss -tulpn | grep -E ':80|:443|:8080'  # ¿escucha el servicio?
sudo tail -n 100 /var/log/syslog         # ¿qué dice el sistema?
sudo journalctl -u mi-api -n 100 --no-pager  # ¿y el servicio?

# ── 7. BACKUP ───────────────────────────────────────────
tar -czf "/tmp/mi-api-$(date +%F).tar.gz" -C /opt mi-api
rsync -avz "/tmp/mi-api-$(date +%F).tar.gz" usuario@backup:/backups/
```

</details>

---

## ⏭️ Para después

Existe, es útil, pero no lo necesitas hoy:

- `sed`, `awk` a fondo (ver `grep-sed-awk.md`)
- `logrotate`: rotación de logs
- LVM, RAID, `fdisk`/`parted`, `fstab`: gestión avanzada de discos
- `iptables` / `nftables` (ver `ufw-nftables.md`)
- `cgroups`, `namespaces`: base de cómo funcionan los contenedores
- `strace`, `perf`, `ltrace`: depuración de bajo nivel (ver `debugging-htop-strace-lsof.md`)
- `sysctl` y tuning del kernel
- ACLs (`setfacl`/`getfacl`), SELinux/AppArmor
- `at`, `anacron` (cron ya está en `cron.md`)
- `screen` (usa `tmux`, ver `tmux.md`)

---

## Referencias

- The Linux Command Line (gratis): <https://linuxcommand.org/tlcl.php>
- Debian Reference: <https://www.debian.org/doc/manuals/debian-reference/>
- Filesystem Hierarchy Standard: <https://refspecs.linuxfoundation.org/fhs.shtml>
- explainshell (desglosa cualquier comando): <https://explainshell.com>