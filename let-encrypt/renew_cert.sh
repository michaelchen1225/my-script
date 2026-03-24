#!/bin/bash

# Configuration
CERT_FILE="/data/certbot_data/conf/live/dhub.hinet.net/fullchain.pem"
# Corrected image tag as per your update
CERTBOT_IMAGE="harbor.cht.com.tw:30725/p4u-project/shared/aud/docker-certbot:28.3.3-dind"
VOLUMES="-v /data/certbot_data/conf:/etc/letsencrypt -v /data/certbot_data/www:/var/www/certbot"

# 1. Check expiration using openssl
EXP_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
EXP_SECONDS=$(date -d "$EXP_DATE" +%s)
NOW_SECONDS=$(date +%s)
THRESHOLD_SECONDS=$(( 30 * 24 * 3600 )) # 30 days in seconds

# 2. Logic check
if [ $(( EXP_SECONDS - NOW_SECONDS )) -le $THRESHOLD_SECONDS ]; then
    echo "$(date): Certificate expires soon. Starting Docker renewal..."
    
    # Run Certbot and capture all output (stdout and stderr) into a variable
    # Removed --quiet so we can actually see what happened in the log if it fails
    RENEW_OUTPUT=$(docker run --rm $VOLUMES $CERTBOT_IMAGE certbot renew 2>&1)
    EXIT_CODE=$?
    
    # 3. Handle results
    if [ $EXIT_CODE -eq 0 ]; then
        echo "$(date): Renewal successful."
        echo "Certbot Output: $RENEW_OUTPUT"
        echo "Reloading Nginx daemon..."
        systemctl reload nginx
    else
        echo "$(date): ERROR - Certbot renewal failed with exit code $EXIT_CODE."
        echo "-------------------------------------------"
        echo "FULL CERTBOT ERROR OUTPUT:"
        echo "$RENEW_OUTPUT"
        echo "-------------------------------------------"
        exit 1
    fi
else
    echo "$(date): Certificate is still valid ($(( (EXP_SECONDS - NOW_SECONDS) / 86400 )) days left). No action taken."
fi