#!/bin/sh
#
## Check DDNS Record
#
# Run this script on pfsense and schedule via cron
#
#. Lookup current IP
#  Performs a DNS lookup
#  Compare current IP and DNS Record returned IP
#  Send the result to the Uptime Kuma Push URL
#
# run every day
# 0 * * * * /home/[USERID]/check-ddns-record.sh
#

#!/bin/sh

# Define constants
BASE_URL='https://uptimekuma.yourdomain.com/api/push/c8ArlWc7Q3?status='
DOMAIN=''

# Set up logging
LOG_FILE="/home/[USERID]/logs/check-ddns-record.log"
MAX_LOG_SIZE=1048576 # 1 MB

# Function to log messages
log() {
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP $1" >> "$LOG_FILE"
}

# Function to check if log file exists
check_log_exists() {
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
    fi
}

# Function to check log file size and delete if exceeds limit
check_log_size() {
    FILESIZE=$(du -B1 "$LOG_FILE" | cut -f1)
    if [ $FILESIZE -ge $MAX_LOG_SIZE ]; then
        rm "$LOG_FILE"
        echo "Deleted $LOG_FILE due to size limit reached."
        touch "$LOG_FILE"
    fi
}

check_log_exists
check_log_size
log "START"
log "BASE_URL: $BASE_URL"

# Perform the DDNS IP comparison test
CURRENT_IP=$(dig @1.1.1.1 ch txt whoami.cloudflare +short | tr -d '"')
DDNS_IP=$(dig @1.1.1.1 $DOMAIN +short)

if [ "$CURRENT_IP" == "$DDNS_IP" ]; then
    STATUS="up"
    MESSAGE="OK"
else
    STATUS="down" 
    MESSAGE="DDNS ($DDNS_IP) does not match ($CURRENT_IP)"
fi

log "Current IP: $CURRENT_IP"
log "DDNS IP: $DDNS_IP"
log "STATUS: $STATUS"

# Encode the RESULT to be URL-safe
ENCODED_MESSAGE=$(echo "$MESSAGE" | jq -sRr @uri)

# Construct the request URL with the encoded result
URL="${BASE_URL}${STATUS}&msg=${ENCODED_MESSAGE}"
log "FULL_URL: $URL"

# Execute the HTTP request
RESPONSE=$(curl --max-time 5 -s -o /dev/null -w "%{http_code}" "$URL")
if [ $? -eq 0 ]; then
    log "CURL command executed. Response status: $RESPONSE"
else
    log "Failed to execute CURL command."
fi
