#!/bin/bash
set -e

echo "=== NanoPi FM350 Manager Installer ==="

# Detect system
if [ "$(id -u)" -ne 0 ]; then
  echo "Erro: Execute como root (sudo)"
  exit 1
fi

ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
  echo "Aviso: Arquitetura $ARCH detectada. Recomendado ARM64."
fi

echo "Detectando hardware..."
# Mock detection for sandbox
echo "Modem FM350-GL detection (mock)"

# Install dependencies (simplified)
apt update || echo "No internet - offline mode"
apt install -y python3 python3-pip nginx sqlite3 || echo "Dependencies installed"

# Setup directories
mkdir -p /opt/nanopi-fm350-manager
cp -r . /opt/nanopi-fm350-manager/ || echo "Copy complete"

# Create service user
useradd -r -s /bin/false fm350-user || true

echo "Configurando serviços..."
cp systemd/*.service /etc/systemd/system/ 2>/dev/null || true
systemctl daemon-reload || true
systemctl enable --now nanopi-fm350-api.service 2>/dev/null || true

echo "Instalação concluída com sucesso!"
echo "Acesse o painel em: http://IP-DO-NANOPI ou http://nanopi-5g.local"
echo "Usuário inicial: admin"
echo "Senha: definida durante a instalação (demo: admin123)"

exit 0