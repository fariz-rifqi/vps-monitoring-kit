#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"

log(){ echo -e "\n[+] $*\n"; }

log "Install Netdata (Parent)"
bash <(curl -fsSL https://get.netdata.cloud/kickstart.sh) --stable-channel --disable-telemetry || true
systemctl enable --now netdata

log "Configure Netdata as Parent receiver (streaming)"
STREAM_CONF="/etc/netdata/stream.conf"
NETDATA_CONF="/etc/netdata/netdata.conf"

# generate shared api key once
KEY_FILE="/root/netdata_stream_api_key.txt"
if [[ ! -f "${KEY_FILE}" ]]; then
  KEY="$(cat /proc/sys/kernel/random/uuid)"
  echo "${KEY}" > "${KEY_FILE}"
else
  KEY="$(cat "${KEY_FILE}")"
fi

cat > "${STREAM_CONF}" <<EOF
[stream]
  enabled = yes
  enable compression = yes
  api key = ${KEY}
  default history = 3600
EOF

# Bind web UI to localhost for safety (served via nginx)
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

log "Configure Telegram alerts for Netdata (optional)"
# Netdata uses health_alarm_notify.conf for notifications
# We'll configure only if TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID are provided.
if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" && "${TELEGRAM_BOT_TOKEN}" != "replace_me" && "${TELEGRAM_CHAT_ID}" != "replace_me" ]]; then
  NOTIFY_CONF="/etc/netdata/health_alarm_notify.conf"
  if [[ -f "${NOTIFY_CONF}" ]]; then
    cp -f "${NOTIFY_CONF}" "${NOTIFY_CONF}.bak" || true
  fi

  # ensure enabled
  sed -i 's/^#\? *SEND_TELEGRAM=.*/SEND_TELEGRAM="YES"/' "${NOTIFY_CONF}" || true
  sed -i 's/^#\? *TELEGRAM_BOT_TOKEN=.*/TELEGRAM_BOT_TOKEN="'"${TELEGRAM_BOT_TOKEN}"'"/' "${NOTIFY_CONF}" || true
  sed -i 's/^#\? *TELEGRAM_CHAT_ID=.*/TELEGRAM_CHAT_ID="'"${TELEGRAM_CHAT_ID}"'"/' "${NOTIFY_CONF}" || true

  # restart to apply
  systemctl restart netdata
  log "Netdata Telegram alerts configured."
else
  log "Telegram token/chat_id not set. Skipping Netdata Telegram config (you can set later in .env and rerun this script)."
fi

log "Netdata Parent ready. Streaming API key saved at ${KEY_FILE}"
echo "Netdata Streaming API Key: $(cat /root/netdata_stream_api_key.txt)"
