#!/usr/bin/env bash

source <(curl -fsSL https://raw.githubusercontent.com/atolycs/bash-util-closet/main/logs.func)

msg_info "ArchLinux Live Session SSH setup..."

echo "Step1: Checking commands..."

# curl
if ! hash curl 2>/dev/null; then
  echo "Required curl"
fi

# jq
if ! hash jq 2>/dev/null; then
  echo "Required jq"
fi

echo "Step2: Setup SSH configuration..."

cat <<EOF >/etc/ssh/sshd_config.d/99-livesession.conf
PubkeyAuthentication yes
EOF

echo "Step3: Downloading SSH Public key from GitHub..."
curl -fsSL https://api.github.com/uesrs/atolycs/keys | jq -r '.[].key' | tee -a ${HOME}/.ssh/authorized_keys

echo "Setup complited."
echo "IPv4 Address: $(ip route get 1.1.1.1 | awk '{print $7; exit'})"
