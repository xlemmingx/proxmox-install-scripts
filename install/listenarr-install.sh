#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: community-scripts (based on tteck's work)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Listenarrs/Listenarr

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  unzip \
  sqlite3
msg_ok "Installed Dependencies"

msg_info "Installing ${APP}"
# Self-contained binary — no .NET runtime needed
RELEASE=$(curl -fsSL "https://api.github.com/repos/Listenarrs/Listenarr/releases/latest" \
  | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

mkdir -p /opt/Listenarr
curl -fsSL \
  "https://github.com/Listenarrs/Listenarr/releases/download/${RELEASE}/listenarr-linux-x64.zip" \
  -o /tmp/Listenarr.zip
unzip -q /tmp/Listenarr.zip -d /opt/Listenarr
rm -f /tmp/Listenarr.zip
chmod +x /opt/Listenarr/Listenarr.Api
msg_ok "Installed ${APP} ${RELEASE}"

msg_info "Creating Service User"
useradd -r -s /bin/false listenarr 2>/dev/null || true
chown -R listenarr:listenarr /opt/Listenarr
msg_ok "Created Service User"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/listenarr.service
[Unit]
Description=Listenarr Audiobook Manager
After=network.target

[Service]
User=listenarr
Group=listenarr
WorkingDirectory=/opt/Listenarr
ExecStart=/opt/Listenarr/Listenarr.Api
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now listenarr
msg_ok "Created and Started Service"

motd_ssh
customize
