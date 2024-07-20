# About
Check the DNS Record matches the current IP and **alert** when it's not.
# Getting Started
## Prerequisites

* pfsense 2.7.2
* Uptime Kuma 

In Uptime Kuma create a Push Monitor and note the Push URL.

## Installation
Download script to your pfsense home directory
```bash
wget https://github.com/hhanzo1/check-tunnel/blob/main/check-ddns-record.sh
chmod +x check-ddns-record.sh
```

Replace the domain in the BASE_URL and DOMAIN.

# Usage
Test the script is running as expected by running manually, then scheduled via cron.

## Enable the check script
```bash
# Run every hour
0 * * * * /home/[USERID]/check-ddns-record.sh
```
If the Push URL does not receive a HTTP request within Heart Beat internal (default 60 seconds), an alert can be triggered.

## View Badges
Status and Uptime [Uptime Kuma Badges](https://github.com/louislam/uptime-kuma/wiki/Badge) can be configured.

![tunnel status](https://uptime.netwrk8.com/api/badge/12/status)
![tunnel uptime](https://uptime.netwrk8.com/api/badge/12/uptime)
![tunnel uptime 30d](https://uptime.netwrk8.com/api/badge/12/uptime/720?label=Uptime(30d)&labelSuffix=d)

# Acknowledgments
* [pfsense](https://www.pfsense.org/)
* [Uptime Kuma](https://github.com/louislam/uptime-kuma)
