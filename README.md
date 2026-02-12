# CraftbyZR Monitoring

Centralized monitoring stack for managing multiple VPS used for: - Web
Profile / Company Profile - E-commerce - Web Apps (Laravel, Node, Go,
Python)

Built with a lightweight approach suitable for **2 vCPU / 2 GB RAM**
monitoring server.

------------------------------------------------------------------------

## 🚀 Features

-   **Netdata Parent--Child Streaming**
    -   Real-time resource metrics (CPU, RAM, Disk, Network)
    -   Service metrics: Nginx, MySQL/Postgres, Redis
    -   Central dashboard for all VPS
-   **Uptime Kuma**
    -   Website uptime monitoring
    -   SSL expiry check
    -   Response time monitoring
    -   Telegram/Email alerts
-   **Security First**
    -   Nginx reverse proxy + Basic Auth
    -   UFW firewall
    -   Fail2ban
    -   HTTPS via Let's Encrypt
-   **Backup Ready**
    -   Database backup scripts
    -   File backup scripts
    -   Restore procedures

------------------------------------------------------------------------

## 🧩 Architecture

    [VPS Client A] ── Netdata Child ─┐
    [VPS Client B] ── Netdata Child ─┼──> [Monitoring VPS]
    [VPS Client C] ── Netdata Child ─┘      ├─ Netdata Parent
                                            ├─ Uptime Kuma
                                            └─ Nginx + SSL

------------------------------------------------------------------------

## 📦 Repository Structure

    monitoring-server/   → Setup for monitoring VPS
    client/              → Script for each client VPS
    backup/              → Backup utilities
    alerts/              → Alert configuration
    docs/                → Guides & architecture

------------------------------------------------------------------------

## 🛠 Requirements

### Monitoring VPS

-   Ubuntu 22.04 LTS (recommended)
-   2 vCPU / 2 GB RAM
-   40--60 GB SSD
-   Domain or subdomain (recommended)

### Client VPS

-   Ubuntu / Debian
-   Outbound access to monitoring VPS
-   Netdata agent installed

------------------------------------------------------------------------

## ⚡ Quick Start

### 1. Setup Monitoring Server

``` bash
sudo bash monitoring-server/install.sh
```

After installation:

-   Netdata: `https://monitor.yourdomain.com/netdata/`
-   Kuma: `https://monitor.yourdomain.com/kuma/`

------------------------------------------------------------------------

### 2. Setup Client VPS

On each VPS to be monitored:

``` bash
sudo bash client/install.sh
```

Edit configuration:

    PARENT_IP=your_monitoring_ip
    STREAM_API_KEY=key_from_parent

------------------------------------------------------------------------

## 🔔 Alerts

Default alerts include:

-   CPU \> 80%
-   RAM \> 85%
-   Disk \> 80%
-   Service down
-   SSL expiry \< 14 days

Supported channels:

-   Telegram\
-   Email

See: `alerts/telegram.md`

------------------------------------------------------------------------

## 🔐 Security Notes

-   Dashboard protected with Basic Auth
-   Access via HTTPS only
-   Firewall restricts unnecessary ports
-   Fail2ban enabled

Recommended:

-   Use Cloudflare Tunnel or IP allowlist
-   Do not expose Netdata child dashboards

------------------------------------------------------------------------

## 💾 Backup

-   Daily DB backup
-   Weekly file backup
-   Offsite storage recommended
-   Restore test monthly

See: `backup/README.md`

------------------------------------------------------------------------

## 🧪 Supported Stacks

### Laravel

-   Nginx metrics\
-   MySQL/Postgres metrics\
-   Redis metrics

### Node

-   System metrics\
-   PM2/Docker metrics

### Go

-   System metrics\
-   App health endpoint

### Python

-   System metrics\
-   Gunicorn metrics

------------------------------------------------------------------------

## 📌 Limitations (2GB Monitoring VPS)

-   Recommended ≤ 15 VPS
-   Retention 7--14 days
-   Use Netdata + Kuma (Prometheus optional)

------------------------------------------------------------------------

## 🤝 Contributing

Internal use for CraftbyZR projects.\
Pull requests welcome for improvements.

------------------------------------------------------------------------

## 📄 License

MIT
