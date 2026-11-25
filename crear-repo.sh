#!/usr/bin/env bash
set -euo pipefail

mkdir -p cheatsheets && cd cheatsheets

declare -A estructura=(
  ["01-terminal-y-sistema"]="linux bash-scripting vim tmux grep-sed-awk jq ssh curl systemd apt-dpkg cron"
  ["02-git-y-colaboracion"]="git github-cli conventional-commits"
  ["03-contenedores"]="docker docker-compose kubernetes helm"
  ["04-bases-de-datos/postgresql"]="psql sql-esencial indices-explain backups jsonb"
  ["04-bases-de-datos/nosql"]="redis mongodb postgres-vs-redis-vs-mongo"
  ["05-redes-y-servidores"]="nginx dns-tcp-ip tls-openssl ufw-nftables wireguard"
  ["06-ci-cd-y-automatizacion"]="github-actions make"
  ["07-infraestructura-como-codigo"]="ansible terraform"
  ["08-cloud-gcp"]="gcloud-cli iam-service-accounts compute-vpc cloud-run cloud-sql gke"
  ["09-observabilidad"]="logs-journalctl debugging-htop-strace-lsof prometheus-grafana"
  ["10-seguridad"]="gpg ssh-hardening secretos-vault-sops"
)

for carpeta in "${!estructura[@]}"; do
  mkdir -p "$carpeta"
  for archivo in ${estructura[$carpeta]}; do
    titulo="${archivo//-/ }"
    printf '# %s\n\n> Descripción breve.\n\n## Comandos esenciales\n\n' "$titulo" > "$carpeta/$archivo.md"
  done
done

echo "# Cheatsheets" > README.md
echo "Estructura creada en $(pwd)"

cat > _plantilla.md <<'EOF'
# Nombre de la herramienta

> Una línea: qué es y para qué sirve.

## Instalación / verificación
## Comandos esenciales
## Casos de uso frecuentes
## Trucos y one-liners
## Errores comunes
## Referencias
EOF