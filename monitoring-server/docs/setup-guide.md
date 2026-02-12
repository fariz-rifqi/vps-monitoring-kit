# Monitoring Server Setup Guide (monitor.craftbyzr.my.id)

## 1) DNS
Create an **A record**:
- Name: `monitor`
- Type: `A`
- Value: `<YOUR_VPS_PUBLIC_IP>`

## 2) Install
On the VPS:

```bash
cd monitoring-server
cp .env.example .env
nano .env
sudo bash install.sh
```

## 3) Access
- Netdata: `https://monitor.craftbyzr.my.id/netdata/`
- Kuma: `https://monitor.craftbyzr.my.id/kuma/`

## 4) Add Telegram Alerts
- Netdata: set token/chat id in `.env`, rerun netdata parent script
- Kuma: set in UI (Settings → Notifications)

## 5) Add Client Nodes
Run the Netdata child installer on each client VPS (in `client/` folder of the main repo).
