#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"

log(){ echo -e "\n[+] $*\n"; }

log "Install Netdata agent (child)"
bash <(curl -fsSL https://get.netdata.cloud/kickstart.sh) --stable-channel --disable-telemetry || true
systemctl enable --now netdata

log "Configure streaming to parent"
STREAM_CONF="/etc/netdata/stream.conf"

cat > "${STREAM_CONF}" <<EOF
[stream]
  enabled = yes
  destination = ${PARENT_IP}:${PARENT_PORT}
  api key = ${STREAM_API_KEY}
  timeout seconds = 60
EOF

# Optional: set hostname for nicer dashboard name
if [[ -n "${CHILD_NAME:-}" ]]; then
  echo "${CHILD_NAME}" > /etc/netdata/hostname
fi

# Security: bind Netdata web UI to localhost (optional).
# We don't need to expose child dashboard publicly.
NETDATA_CONF="/etc/netdata/netdata.conf"
if [[ -f "${NETDATA_CONF}" ]]; then
  if ! grep -q "^\[web\]" "${NETDATA_CONF}"; then
    echo -e "\n[web]\n" >> "${NETDATA_CONF}"
  fi
  if grep -q "^\s*bind to\s*=" "${NETDATA_CONF}"; then
    sed -i 's/^\s*bind to\s*=.*/  bind to = 127.0.0.1/' "${NETDATA_CONF}"
  else
    awk '
      BEGIN{added=0}
      /^\[web\]/{print; print "  bind to = 127.0.0.1"; added=1; next}
      {print}
      END{if(!added){print "[web]\n  bind to = 127.0.0.1"}}
    ' "${NETDATA_CONF}" > /tmp/netdata.conf && mv /tmp/netdata.conf "${NETDATA_CONF}"
  fi
fi

systemctl restart netdata

log "Netdata child ready. It will appear in parent dashboard shortly."
