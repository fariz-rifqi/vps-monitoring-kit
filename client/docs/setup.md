# Client VPS Setup (Netdata Child)

## 1) Prepare .env
```bash
cp .env.example .env
nano .env
```

Required:
- `PARENT_IP` = IP of monitoring server
- `STREAM_API_KEY` = value from monitoring server:
  ```bash
  sudo cat /root/netdata_stream_api_key.txt
  ```

Optional:
- `CHILD_NAME` for a friendly server name

## 2) Install
```bash
sudo bash install.sh
```

## 3) Verify
Open Netdata dashboard on monitoring server:
- https://monitor.craftbyzr.my.id/netdata/

Your node should appear within a minute.
