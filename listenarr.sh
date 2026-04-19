#!/usr/bin/env bash
COMMUNITYSCRIPTSURL="https://raw.githubusercontent.com/xlemmingx/proxmox-install-scripts/main"
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: community-scripts (based on tteck's work)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Listenarrs/Listenarr

APP="Listenarr"
var_tags="${var_tags:-arr}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"
var_install="${var_install:-listenarr-install}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/Listenarr ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  RELEASE=$(curl -fsSL "https://api.github.com/repos/Listenarrs/Listenarr/releases/latest" \
    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

  msg_info "Stopping ${APP} Service"
  systemctl stop listenarr
  msg_ok "Stopped Service"

  msg_info "Updating ${APP} to ${RELEASE}"
  curl -fsSL "https://github.com/Listenarrs/Listenarr/releases/download/${RELEASE}/listenarr-linux-x64.zip" \
    -o /tmp/Listenarr.zip
  rm -rf /opt/Listenarr
  mkdir -p /opt/Listenarr
  unzip -q /tmp/Listenarr.zip -d /opt/Listenarr
  rm -f /tmp/Listenarr.zip
  chmod +x /opt/Listenarr/Listenarr.Api
  chown -R listenarr:listenarr /opt/Listenarr
  msg_ok "Updated to ${RELEASE}"

  msg_info "Starting ${APP} Service"
  systemctl start listenarr
  msg_ok "Started Service"
  msg_ok "Updated successfully!"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:4545${CL}"
