# client

This folder installs **Netdata Child/Agent** on each VPS you want to monitor.

## Quick Start

```bash
cp .env.example .env
nano .env
sudo bash install.sh
```

## Notes
- Netdata child dashboard is bound to localhost by default for security.
- Metrics are streamed to the Netdata Parent on the monitoring server.
