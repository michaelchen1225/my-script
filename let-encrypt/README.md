# Let's Encrypt

## Renew certificate

### quick install

```bash
curl -k --tlsv1.2 -O https://raw.githubusercontent.com/michaelchen1225/my-script/refs/heads/master/let-encrypt/renew_cert.sh

chmod +x renew_cert.sh

cp cert-renew.sh /usr/local/bin/renew_cert.sh
```


### Recommended (crontab)

```bash id="6n6jhc"
# Run every day at 3 AM
echo "0 3 * * * /usr/local/bin/cert-renew.sh >> /var/log/cert-renew.log 2>&1" | crontab -

crontab -l
```

---

### Key features

> Automatically renew TLS certificates before expiration using Dockerized Certbot

* Checks certificate expiration using `openssl`
* Automatically renews when remaining validity ≤ 30 days
* Uses Docker to run Certbot (no host install needed)
* Captures full Certbot output for debugging
* Reloads Nginx after successful renewal
* Safe execution with clear success/failure logs

---

### How it works

1. Read certificate expiration date from local `.pem` file
2. Convert expiration time into seconds and compare with current time
3. If remaining time ≤ 30 days:

   * Run `certbot renew` via Docker
   * Capture output and exit code
   * Reload Nginx if successful
4. Otherwise:

   * Skip renewal and print remaining days

---

### Usage

```bash id="w1c3tb"
# Run manually
cert-renew.sh
```

---

### Configuration

```bash id="3m9j2g"
CERT_FILE="/data/certbot_data/conf/live/dhub.hinet.net/fullchain.pem"

CERTBOT_IMAGE="harbor.cht.com.tw:30725/p4u-project/shared/aud/docker-certbot:28.3.3-dind"

VOLUMES="-v /data/certbot_data/conf:/etc/letsencrypt \
         -v /data/certbot_data/www:/var/www/certbot"
```

---

### Notes

* Requires Docker installed and running
* Nginx must be managed by `systemctl`
* Make sure certificate paths and volumes are correct
* Logs include full Certbot output for troubleshooting
* You can adjust the renewal threshold (default: 30 days)
