# Git

> Sistema de control de versiones distribuido. Guarda la historia de tu proyecto como una serie de "fotos" (commits), te permite trabajar en ramas paralelas y colaborar con otros mediante repositorios remotos.

## Índice

1. [Configuración inicial](#1-configuración-inicial)
2. [Crear y clonar repositorios](#2-crear-y-clonar-repositorios)
3. [Ciclo básico de trabajo](#3-ciclo-básico-de-trabajo)
4. [Deshacer cambios](#4-deshacer-cambios)
5. [Ramas](#5-ramas)
6. [Remotos](#6-remotos)
7. [Stash](#7-stash-guardar-cambios-temporales)
8. [Rebase](#8-rebase)
9. [Historial y búsqueda](#9-historial-y-búsqueda)
10. [Tags y versiones](#10-tags-y-versiones)
11. [.gitignore](#11-gitignore)
12. [Ejemplo completo de la herramienta](#-ejemplo-completo-de-la-herramienta)
13. [Para después](#️-para-después)

**Modelo mental rápido:**

```
Working directory  ──git add──▶  Staging area  ──git commit──▶  Repositorio local  ──git push──▶  Remoto
   (tus archivos)                 (lo que irá                     (historia)                      (GitHub)
                                   en el commit)
```

---

## 1. Configuración inicial

**Concepto:** Git necesita saber quién eres (aparece en cada commit) y algunas preferencias. Se hace una sola vez por máquina.

| Comando | Qué hace |
|---|---|
| `git config --global user.name "Nombre"` | Define tu nombre |
| `git config --global user.email "mail"` | Define tu correo (el mismo que en GitHub) |
| `git config --global init.defaultBranch main` | Rama inicial por defecto |
| `git config --global pull.rebase true` | `git pull` hace rebase en lugar de merge |
| `git config --global core.editor "vim"` | Editor para mensajes de commit |
| `git config --global alias.st "status -sb"` | Crea un atajo |
| `git config --global --list` | Muestra toda tu configuración |

**Ejemplo:**

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@correo.com"
git config --global init.defaultBranch main
```

<details>
<summary>🏭 Ejemplo completo: configuración de producción</summary>

```bash
# Identidad
git config --global user.name "Tu Nombre"
git config --global user.email "tu@correo.com"

# Rama por defecto moderna
git config --global init.defaultBranch main

# Evita merge commits innecesarios al hacer pull (historia lineal)
git config --global pull.rebase true

# Al hacer push de una rama nueva, la crea en el remoto automáticamente
git config --global push.autoSetupRemote true

# Limpia referencias a ramas remotas borradas cada vez que haces fetch
git config --global fetch.prune true

# Mejor formato de conflictos: muestra también el ancestro común
git config --global merge.conflictstyle zdiff3

# Editor
git config --global core.editor "vim"

# Aliases útiles
git config --global alias.st "status -sb"
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.last "log -1 --stat"
```

Se guarda en `~/.gitconfig`. Puedes versionar ese archivo en tu repo de dotfiles.

</details>

---

## 2. Crear y clonar repositorios

**Concepto:** o empiezas un repo desde cero (`init`) o descargas uno existente con toda su historia (`clone`).

| Comando | Qué hace |
|---|---|
| `git init` | Convierte la carpeta actual en repo |
| `git clone <url>` | Descarga un repo remoto |
| `git clone <url> carpeta` | Lo descarga en una carpeta con otro nombre |
| `git clone --depth 1 <url>` | Clon superficial (solo el último commit, más rápido) |
| `git remote add origin <url>` | Conecta tu repo local con un remoto |

**Ejemplo:**

```bash
git clone git@github.com:usuario/proyecto.git
cd proyecto
```

<details>
<summary>🏭 Ejemplo completo: proyecto nuevo desde cero hasta GitHub</summary>

```bash
mkdir mi-api && cd mi-api
git init

# Primero el .gitignore y un README, antes de cualquier otra cosa
printf 'node_modules/\n.env\n*.log\n' > .gitignore
echo "# mi-api" > README.md

git add .
git commit -m "chore: commit inicial"

# Conectar con el repo vacío que creaste en GitHub (usa SSH, no HTTPS)
git remote add origin git@github.com:usuario/mi-api.git
git push -u origin main
```

`-u` guarda la relación entre tu rama local y la remota, así después basta con `git push`.

</details>

---

## 3. Ciclo básico de trabajo

**Concepto:** el 90% de tu día con Git es: ver qué cambió, preparar cambios, confirmarlos.

| Comando | Qué hace |
|---|---|
| `git status` | Estado actual: qué cambió, qué está preparado |
| `git status -sb` | Versión corta con la rama |
| `git add archivo` | Prepara un archivo |
| `git add .` | Prepara todo lo del directorio actual |
| `git add -p` | Prepara por fragmentos, eligiendo interactivamente |
| `git diff` | Cambios sin preparar |
| `git diff --staged` | Cambios preparados (lo que irá en el commit) |
| `git commit -m "mensaje"` | Crea un commit |
| `git commit` | Abre el editor para un mensaje largo |
| `git log --oneline` | Historia resumida, una línea por commit |
| `git log --oneline --graph --all` | Historia con forma de árbol |

**Ejemplo:**

```bash
git status
git diff                      # revisa antes de preparar
git add -p                    # elige qué entra
git diff --staged             # revisa lo que va a entrar
git commit -m "feat: agrega endpoint de login"
```

**Formato del mensaje (Conventional Commits):**

| Prefijo | Cuándo |
|---|---|
| `feat:` | Nueva funcionalidad |
| `fix:` | Corrección de bug |
| `docs:` | Solo documentación |
| `refactor:` | Cambio de código sin cambiar comportamiento |
| `test:` | Agregar o corregir pruebas |
| `chore:` | Mantenimiento, dependencias, configuración |
| `ci:` | Cambios en pipelines |

<details>
<summary>🏭 Ejemplo completo: un commit bien hecho</summary>

```bash
# 1. Revisa qué cambió
git status -sb
git diff

# 2. Prepara solo lo relacionado con UN cambio lógico (commits pequeños y atómicos)
git add -p

# 3. Verifica exactamente lo que se va a guardar
git diff --staged

# 4. Commit con mensaje descriptivo: tipo, alcance opcional, resumen en imperativo
git commit -m "fix(auth): valida expiración del token antes de refrescar"

# Para un cambio que merece explicación, usa el editor (sin -m):
#   Línea 1: resumen de máximo ~72 caracteres
#   Línea en blanco
#   Cuerpo: POR QUÉ se hizo el cambio, no qué (eso lo dice el diff)
git commit
```

Regla práctica: si necesitas escribir "y" en el mensaje ("agrega login y arregla el footer"), probablemente son dos commits.

</details>

---

## 4. Deshacer cambios

**Concepto:** casi todo en Git se puede deshacer. Elegir el comando correcto depende de si el cambio ya se subió o no.

| Situación | Comando |
|---|---|
| Descartar cambios en un archivo (sin preparar) | `git restore archivo` |
| Sacar un archivo del staging (conserva cambios) | `git restore --staged archivo` |
| Corregir el último commit (mensaje o contenido) | `git commit --amend` |
| Deshacer el último commit, conservando los cambios | `git reset --soft HEAD~1` |
| Deshacer el último commit y sacarlo del staging | `git reset HEAD~1` |
| Deshacer el último commit y **borrar** los cambios | `git reset --hard HEAD~1` ⚠️ |
| Deshacer un commit ya subido (crea uno nuevo inverso) | `git revert <hash>` |
| Eliminar archivos sin seguimiento | `git clean -fd` ⚠️ |

**Regla de oro:** si ya hiciste `push`, usa `revert`. Si es solo local, puedes usar `reset` o `amend`.

**Ejemplo:**

```bash
git restore src/app.js              # descarta cambios de un archivo
git restore --staged src/app.js     # lo saca del staging
git commit --amend --no-edit        # agrega lo preparado al último commit
git revert a1b2c3d                  # deshace un commit ya publicado
```

<details>
<summary>🏭 Ejemplo completo: me equivoqué, ¿qué hago?</summary>

```bash
# CASO A: Edité un archivo y quiero volver a como estaba
git restore src/config.js

# CASO B: Hice git add de algo que no debía
git restore --staged .env

# CASO C: Commiteé y olvidé un archivo (aún NO hice push)
git add archivo-olvidado.js
git commit --amend --no-edit

# CASO D: El mensaje del último commit tiene un error (aún NO hice push)
git commit --amend -m "fix(auth): mensaje corregido"

# CASO E: Hice 3 commits locales que quiero rehacer, conservando el código
git reset --soft HEAD~3
# ...ahora todo está en staging, reorganiza y commitea de nuevo

# CASO F: Ya hice push de un commit malo
git revert a1b2c3d
git push

# CASO G: Hice reset --hard y me arrepentí
git reflog                  # busca el hash de antes del reset
git reset --hard HEAD@{2}   # vuelve a ese punto
```

⚠️ Nunca reescribas historia (`amend`, `reset`, `rebase`) de commits que otras personas ya descargaron.

</details>

---

## 5. Ramas

**Concepto:** una rama es una línea de desarrollo independiente. Trabajas en tu cambio sin afectar `main` y luego lo integras.

| Comando | Qué hace |
|---|---|
| `git branch` | Lista ramas locales |
| `git branch -a` | Lista locales y remotas |
| `git switch rama` | Cambia a una rama existente |
| `git switch -c nueva-rama` | Crea y cambia a una rama nueva |
| `git merge rama` | Integra `rama` en la rama actual |
| `git merge --no-ff rama` | Fuerza un commit de merge |
| `git branch -d rama` | Borra una rama ya integrada |
| `git branch -D rama` | Borra una rama aunque no esté integrada ⚠️ |
| `git cherry-pick <hash>` | Copia un commit específico a la rama actual |

**Convención de nombres:** `feat/login`, `fix/token-expirado`, `chore/actualizar-deps`.

**Ejemplo:**

```bash
git switch -c feat/login
# ...trabajas y commiteas...
git switch main
git merge feat/login
git branch -d feat/login
```

<details>
<summary>🏭 Ejemplo completo: ciclo de vida de una rama de feature</summary>

```bash
# 1. Parte siempre de main actualizado
git switch main
git pull

# 2. Crea la rama con nombre descriptivo
git switch -c feat/recuperar-password

# 3. Trabaja con commits pequeños
git add -p
git commit -m "feat(auth): agrega endpoint de recuperación"
git commit -m "test(auth): cubre caso de token expirado"

# 4. Sube la rama (con push.autoSetupRemote no hace falta -u)
git push

# 5. Abre un Pull Request (con GitHub CLI)
gh pr create --fill

# 6. Después de que se aprueba y se integra en GitHub, limpia
git switch main
git pull
git branch -d feat/recuperar-password
```

En producción casi nadie hace `merge` directo a `main` desde la terminal: se hace vía Pull Request, con revisión y CI.

**Resolver un conflicto de merge:**

```bash
git merge feat/otra-rama
# CONFLICT en src/app.js

# 1. Abre el archivo, busca las marcas <<<<<<<  =======  >>>>>>>
# 2. Deja la versión correcta y borra las marcas
# 3. Marca como resuelto y termina
git add src/app.js
git commit            # (o git merge --continue)

# Si te asustas, cancela todo y vuelve a como estabas:
git merge --abort
```

</details>

---

## 6. Remotos

**Concepto:** un remoto es una copia del repo en otro lugar (normalmente GitHub). Sincronizas con `fetch`/`pull` (bajar) y `push` (subir).

| Comando | Qué hace |
|---|---|
| `git remote -v` | Lista remotos y sus URLs |
| `git fetch` | Descarga novedades sin tocar tu código |
| `git pull` | `fetch` + integrar en tu rama |
| `git push` | Sube tus commits |
| `git push -u origin rama` | Sube y vincula la rama |
| `git push --force-with-lease` | Fuerza el push de forma segura ⚠️ |
| `git push origin --delete rama` | Borra una rama remota |
| `git remote set-url origin <url>` | Cambia la URL del remoto |

**`fetch` vs `pull`:** `fetch` solo mira qué hay de nuevo; `pull` además lo integra. Ante la duda, haz `fetch` y revisa con `git log HEAD..origin/main`.

**Ejemplo:**

```bash
git fetch
git log --oneline HEAD..origin/main    # qué hay nuevo en remoto
git pull
git push
```

<details>
<summary>🏭 Ejemplo completo: SSH y push seguro después de reescribir historia</summary>

```bash
# Configurar acceso por SSH (una vez por máquina)
ssh-keygen -t ed25519 -C "tu@correo.com"
cat ~/.ssh/id_ed25519.pub        # copia esto en GitHub > Settings > SSH keys
ssh -T git@github.com            # verifica la conexión

# Si tu remoto usa HTTPS, cámbialo a SSH
git remote set-url origin git@github.com:usuario/proyecto.git

# Después de un rebase o amend en TU rama de feature:
# --force-with-lease falla si alguien más subió algo que no has visto.
# Es la versión segura de --force, y la única que deberías usar.
git push --force-with-lease
```

Nunca uses `git push --force` y **jamás** fuerces push a `main`. Activa branch protection en GitHub.

</details>

---

## 7. Stash (guardar cambios temporales)

**Concepto:** guarda tu trabajo a medias sin commitear, para cambiar de rama y recuperarlo después.

| Comando | Qué hace |
|---|---|
| `git stash push -m "msg"` | Guarda cambios con nombre |
| `git stash push -u` | Incluye archivos nuevos sin seguimiento |
| `git stash list` | Lista lo guardado |
| `git stash show -p stash@{0}` | Muestra el contenido de un stash |
| `git stash pop` | Restaura el último y lo elimina |
| `git stash apply` | Restaura sin eliminarlo |
| `git stash drop stash@{0}` | Elimina un stash |

**Ejemplo:**

```bash
git stash push -m "wip: validación de login"
git switch main
# ...atiendes la urgencia...
git switch feat/login
git stash pop
```

<details>
<summary>🏭 Ejemplo completo: interrupción urgente</summary>

```bash
# Estás a medio trabajo en feat/login y llega un bug en producción
git stash push -u -m "wip: formulario de login"

git switch main
git pull
git switch -c fix/error-500-pagos

# ...corriges, commiteas, subes, abres PR...
git commit -m "fix(pagos): maneja respuesta nula del proveedor"
git push
gh pr create --fill

# Vuelves a lo tuyo
git switch feat/login
git stash pop
```

El stash es temporal. Si algo lleva más de un día guardado, mejor hazle un commit en una rama (`wip:`) y lo reordenas después.

</details>

---

## 8. Rebase

**Concepto:** reescribe tus commits sobre otra base, dejando una historia lineal. Sirve para actualizar tu rama con `main` y para limpiar commits antes de un PR.

| Comando | Qué hace |
|---|---|
| `git rebase main` | Pone tus commits encima de `main` actualizado |
| `git rebase -i HEAD~3` | Edita interactivamente los últimos 3 commits |
| `git rebase --continue` | Sigue tras resolver un conflicto |
| `git rebase --abort` | Cancela y vuelve al estado anterior |

**Acciones en `rebase -i`:**

| Acción | Qué hace |
|---|---|
| `pick` | Conserva el commit |
| `reword` | Cambia el mensaje |
| `squash` | Fusiona con el anterior y combina mensajes |
| `fixup` | Fusiona con el anterior descartando su mensaje |
| `drop` | Elimina el commit |

**Ejemplo:**

```bash
git fetch
git rebase origin/main
```

<details>
<summary>🏭 Ejemplo completo: limpiar la rama antes del Pull Request</summary>

```bash
# 1. Actualiza tu rama con lo último de main
git fetch
git rebase origin/main
# Si hay conflictos: resuelve, git add <archivo>, git rebase --continue
# Si te pierdes: git rebase --abort

# 2. Limpia tus commits ("wip", "arreglo", "otra vez") antes de pedir revisión
git rebase -i origin/main
#   pick  a1b2c3d feat(auth): agrega endpoint de recuperación
#   fixup d4e5f6a wip
#   fixup 7g8h9i0 arreglo typo
#   reword 1j2k3l4 test: cubre token expirado

# 3. Sube (la historia cambió, por eso hace falta force-with-lease)
git push --force-with-lease
```

Regla: rebase en **tus** ramas locales o de feature. Nunca en ramas compartidas como `main`.

</details>

---

## 9. Historial y búsqueda

**Concepto:** cuando algo se rompe, Git te dice quién, cuándo y en qué commit.

| Comando | Qué hace |
|---|---|
| `git log --oneline -10` | Últimos 10 commits resumidos |
| `git log -p archivo` | Historia de un archivo con sus cambios |
| `git log --author="nombre"` | Filtra por autor |
| `git log --since="2 weeks ago"` | Filtra por fecha |
| `git log -S"texto"` | Commits que agregaron o quitaron ese texto |
| `git show <hash>` | Detalle de un commit |
| `git blame archivo` | Quién modificó cada línea |
| `git bisect` | Búsqueda binaria del commit que introdujo un bug |
| `git reflog` | Registro de todo lo que ha hecho HEAD (tu red de seguridad) |
| `git grep "texto"` | Busca en los archivos del repo |

**Ejemplo:**

```bash
git log -S"calcularImpuesto" --oneline    # ¿cuándo apareció esta función?
git blame -L 40,60 src/pagos.js           # solo las líneas 40-60
git show a1b2c3d
```

<details>
<summary>🏭 Ejemplo completo: encontrar qué commit rompió algo con bisect</summary>

```bash
# Sabes que hoy está roto y que hace 2 semanas funcionaba
git bisect start
git bisect bad                  # el commit actual está mal
git bisect good v1.4.0          # esta versión sí funcionaba (tag o hash)

# Git te lleva a un commit intermedio. Prueba y responde:
git bisect good    # o:  git bisect bad
# ...repite hasta que Git diga "X is the first bad commit"

git bisect reset                # vuelve a donde estabas

# Automatizado: Git corre tu script en cada paso
git bisect start HEAD v1.4.0
git bisect run ./run-tests.sh   # el script devuelve 0 (bien) o distinto de 0 (mal)
```

Con 1000 commits, `bisect` encuentra el culpable en ~10 pasos.

**`reflog` para recuperar lo "perdido":**

```bash
git reflog
# a1b2c3d HEAD@{0}: reset: moving to HEAD~3
# 9f8e7d6 HEAD@{1}: commit: feat: lo que creías perdido
git reset --hard 9f8e7d6
```

</details>

---

## 10. Tags y versiones

**Concepto:** un tag marca un commit como una versión (`v1.2.0`). Se usa para releases y despliegues.

| Comando | Qué hace |
|---|---|
| `git tag` | Lista tags |
| `git tag -a v1.0.0 -m "msg"` | Crea un tag anotado (el recomendado) |
| `git push origin v1.0.0` | Sube un tag |
| `git push --tags` | Sube todos los tags |
| `git tag -d v1.0.0` | Borra un tag local |
| `git checkout v1.0.0` | Inspecciona el código de esa versión |

**Ejemplo:**

```bash
git tag -a v1.0.0 -m "Primera versión estable"
git push origin v1.0.0
```

<details>
<summary>🏭 Ejemplo completo: publicar una versión</summary>

```bash
git switch main
git pull

# Versionado semántico: MAJOR.MINOR.PATCH
#   PATCH: corrección de bugs     (1.0.0 -> 1.0.1)
#   MINOR: funcionalidad nueva    (1.0.1 -> 1.1.0)
#   MAJOR: cambio incompatible    (1.1.0 -> 2.0.0)
git tag -a v1.1.0 -m "feat: recuperación de contraseña"
git push origin v1.1.0

# Muchos pipelines (GitHub Actions) se disparan al subir un tag v*
# y construyen la imagen Docker o el release automáticamente.
```

</details>

---

## 11. .gitignore

**Concepto:** lista de archivos que Git debe ignorar: dependencias, secretos, archivos generados.

| Patrón | Significado |
|---|---|
| `node_modules/` | Ignora una carpeta |
| `*.log` | Ignora por extensión |
| `.env` | Ignora un archivo concreto |
| `!importante.log` | Excepción: sí se versiona |
| `/build` | Solo en la raíz del repo |

| Comando | Qué hace |
|---|---|
| `git check-ignore -v archivo` | Explica por qué se ignora un archivo |
| `git rm --cached archivo` | Deja de seguir un archivo ya versionado (sin borrarlo) |

**Ejemplo:**

```bash
printf '.env\n*.log\nnode_modules/\n' >> .gitignore
git rm --cached .env      # si ya lo habías subido por error
```

<details>
<summary>🏭 Ejemplo completo: .gitignore típico de backend</summary>

```gitignore
# Secretos: NUNCA al repo
.env
.env.*
!.env.example
*.pem
*.key
credentials.json

# Dependencias y compilados
node_modules/
__pycache__/
*.pyc
dist/
build/
target/

# Logs y temporales
*.log
tmp/

# Editores y sistema
.vscode/
.idea/
.DS_Store

# Datos locales
*.sqlite
data/
```

Commitea un `.env.example` con las claves y valores vacíos para que otros sepan qué variables necesita el proyecto.

⚠️ Si subiste un secreto por error, **ignorar el archivo no basta**: ya está en la historia. Rota (cambia) la credencial de inmediato; reescribir la historia es secundario.

</details>

---

## 🏭 Ejemplo completo de la herramienta

<details>
<summary>Flujo de principio a fin: un día de trabajo en un proyecto real</summary>

```bash
# ── MAÑANA: empezar una tarea ─────────────────────────────
git switch main
git pull                                # main actualizado
git switch -c feat/listar-usuarios      # rama descriptiva

# ── TRABAJO: commits pequeños y atómicos ──────────────────
git status -sb
git add -p                              # revisa lo que entra
git diff --staged
git commit -m "feat(usuarios): agrega endpoint GET /usuarios"

git add -p
git commit -m "test(usuarios): prueba paginación"

# ── INTERRUPCIÓN: bug urgente ─────────────────────────────
git stash push -u -m "wip: filtros"
git switch main && git pull
git switch -c fix/timeout-db
git commit -am "fix(db): sube timeout del pool a 30s"
git push && gh pr create --fill
git switch feat/listar-usuarios
git stash pop

# ── ANTES DEL PR: sincronizar y limpiar ───────────────────
git fetch
git rebase origin/main                  # historia lineal
git rebase -i origin/main               # fixup de commits "wip"
git push --force-with-lease             # push seguro tras reescribir

# ── PR ────────────────────────────────────────────────────
gh pr create --fill
# ...revisión, CI en verde, merge en GitHub...

# ── LIMPIEZA ──────────────────────────────────────────────
git switch main
git pull
git branch -d feat/listar-usuarios

# ── RELEASE ───────────────────────────────────────────────
git tag -a v1.2.0 -m "feat: listado de usuarios"
git push origin v1.2.0

# ── SI ALGO SALE MAL ──────────────────────────────────────
git reflog                              # tu red de seguridad
git merge --abort                       # cancelar un merge
git rebase --abort                      # cancelar un rebase
```

</details>

---

## ⏭️ Para después

Existe, es útil, pero no lo necesitas hoy:

- `git worktree`: varias ramas abiertas a la vez en carpetas distintas
- `git submodule` / `git subtree`: repos dentro de repos
- **Hooks** (`.git/hooks`, `pre-commit`, Husky): validar código antes de cada commit
- **Commits firmados** (GPG/SSH): verificación de autoría
- `git filter-repo`: reescribir toda la historia (por ejemplo, para borrar un secreto)
- `git rerere`: recordar cómo resolviste conflictos repetidos
- `git sparse-checkout`: descargar solo parte de un monorepo
- Estrategias de ramas: GitFlow vs trunk-based
- `git notes`, `git bundle`, `git archive`

---

## Referencias

- Libro oficial (gratis): <https://git-scm.com/book/es/v2>
- Conventional Commits: <https://www.conventionalcommits.org/es/>
- Versionado semántico: <https://semver.org/lang/es/>