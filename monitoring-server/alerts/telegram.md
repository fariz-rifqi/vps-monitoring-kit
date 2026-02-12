# Telegram Alerts (Netdata + Uptime Kuma)

## Netdata → Telegram
Netdata can send alerts to Telegram via `/etc/netdata/health_alarm_notify.conf`.

This repo supports automatic setup using `.env`:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_CHAT_ID`

After updating `.env`, re-run:

```bash
sudo bash monitoring-server/netdata/parent-install.sh
```

## Uptime Kuma → Telegram
In the Kuma UI:
1. Login to `https://monitor.craftbyzr.my.id/kuma/`
2. Settings → Notifications → Telegram
3. Paste bot token + chat id
4. Test and save
