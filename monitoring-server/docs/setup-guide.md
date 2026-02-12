# Setup (Split Subdomains)

## DNS (Cloudflare)
Create **A records** (DNS only while issuing SSL):
- kuma -> <VPS_PUBLIC_IP>
- netdata -> <VPS_PUBLIC_IP>

## Install
```bash
cd monitoring-server
cp .env.example .env
nano .env
sudo bash install.sh
```

## Access
- Kuma: https://kuma.craftbyzr.my.id/
- Netdata: https://netdata.craftbyzr.my.id/
