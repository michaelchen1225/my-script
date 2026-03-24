# Let's Encrypt

## Renew certificate

* Cron job:

```bash
cp ./renew_cert.sh /usr/local/bin/renew_cert.sh
chmod +x /usr/local/bin/renew_cert.sh

# 每天凌晨 2 點執行 renew_cert.sh
echo "0 2 * * * /usr/local/bin/renew_cert.sh >> /var/log/certbot_renew.log 2>&1" | crontab -

crontab -l
```