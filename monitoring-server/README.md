# monitoring-server

This folder installs and configures the **Monitoring VPS** for:

- **Netdata Parent** (central dashboard + streaming receiver)
- **Uptime Kuma** (uptime/SSL checks)
- **Nginx** reverse proxy + Basic Auth
- **HTTPS** via Let's Encrypt (Certbot)
- **Security** (UFW + Fail2ban)

## Quick Start

```bash
cp .env.example .env
nano .env
sudo bash install.sh
```

## Outputs

- Netdata: `https://<MON_DOMAIN>/netdata/`
- Kuma:    `https://<MON_DOMAIN>/kuma/`

See `docs/setup-guide.md`.
