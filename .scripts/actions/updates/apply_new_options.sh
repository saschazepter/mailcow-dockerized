#!/bin/bash

adapt_new_options() {

  CONFIG_ARRAY=(
  "SKIP_LETS_ENCRYPT"
  "SKIP_SOGO"
  "USE_WATCHDOG"
  "WATCHDOG_NOTIFY_EMAIL"
  "WATCHDOG_NOTIFY_WEBHOOK"
  "WATCHDOG_NOTIFY_WEBHOOK_BODY"
  "WATCHDOG_NOTIFY_BAN"
  "WATCHDOG_NOTIFY_START"
  "WATCHDOG_EXTERNAL_CHECKS"
  "WATCHDOG_SUBJECT"
  "SKIP_CLAMD"
  "SKIP_IP_CHECK"
  "ADDITIONAL_SAN"
  "DOVEADM_PORT"
  "IPV4_NETWORK"
  "IPV6_NETWORK"
  "LOG_LINES"
  "SNAT_TO_SOURCE"
  "SNAT6_TO_SOURCE"
  "COMPOSE_PROJECT_NAME"
  "DOCKER_COMPOSE_VERSION"
  "SQL_PORT"
  "API_KEY"
  "API_KEY_READ_ONLY"
  "API_ALLOW_FROM"
  "MAILDIR_GC_TIME"
  "MAILDIR_SUB"
  "ACL_ANYONE"
  "FTS_HEAP"
  "FTS_PROCS"
  "SKIP_FTS"
  "ENABLE_SSL_SNI"
  "ALLOW_ADMIN_EMAIL_LOGIN"
  "SKIP_HTTP_VERIFICATION"
  "SOGO_EXPIRE_SESSION"
  "REDIS_PORT"
  "DOVECOT_MASTER_USER"
  "DOVECOT_MASTER_PASS"
  "MAILCOW_PASS_SCHEME"
  "ADDITIONAL_SERVER_NAMES"
  "ACME_CONTACT"
  "WATCHDOG_VERBOSE"
  "WEBAUTHN_ONLY_TRUSTED_VENDORS"
  "SPAMHAUS_DQS_KEY"
  "SKIP_UNBOUND_HEALTHCHECK"
  "DISABLE_NETFILTER_ISOLATION_RULE"
  "HTTP_REDIRECT"
  )

  sed -i --follow-symlinks '$a\' mailcow.conf
  for option in ${CONFIG_ARRAY[@]}; do
    if [[ ${option} == "ADDITIONAL_SAN" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo "${option}=" >> mailcow.conf
      fi
    elif [[ ${option} == "COMPOSE_PROJECT_NAME" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo "COMPOSE_PROJECT_NAME=mailcowdockerized" >> mailcow.conf
      fi
    elif [[ ${option} == "DOCKER_COMPOSE_VERSION" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo "# Used Docker Compose version" >> mailcow.conf
        echo "# Switch here between native (compose plugin) and standalone" >> mailcow.conf
        echo "# For more informations take a look at the mailcow docs regarding the configuration options." >> mailcow.conf
        echo "# Normally this should be untouched but if you decided to use either of those you can switch it manually here." >> mailcow.conf
        echo "# Please be aware that at least one of those variants should be installed on your maschine or mailcow will fail." >> mailcow.conf
        echo "" >> mailcow.conf
        echo "DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION}" >> mailcow.conf
      fi
    elif [[ ${option} == "DOVEADM_PORT" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo "DOVEADM_PORT=127.0.0.1:19991" >> mailcow.conf
      fi
    elif [[ ${option} == "WATCHDOG_NOTIFY_EMAIL" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo "WATCHDOG_NOTIFY_EMAIL=" >> mailcow.conf
      fi
    elif [[ ${option} == "LOG_LINES" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Max log lines per service to keep in Redis logs' >> mailcow.conf
        echo "LOG_LINES=9999" >> mailcow.conf
      fi
    elif [[ ${option} == "IPV4_NETWORK" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Internal IPv4 /24 subnet, format n.n.n. (expands to n.n.n.0/24)' >> mailcow.conf
        echo "IPV4_NETWORK=172.22.1" >> mailcow.conf
      fi
    elif [[ ${option} == "IPV6_NETWORK" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Internal IPv6 subnet in fc00::/7' >> mailcow.conf
        echo "IPV6_NETWORK=fd4d:6169:6c63:6f77::/64" >> mailcow.conf
      fi
    elif [[ ${option} == "SQL_PORT" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Bind SQL to 127.0.0.1 on port 13306' >> mailcow.conf
        echo "SQL_PORT=127.0.0.1:13306" >> mailcow.conf
      fi
    elif [[ ${option} == "API_KEY" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Create or override API key for web UI' >> mailcow.conf
        echo "#API_KEY=" >> mailcow.conf
      fi
    elif [[ ${option} == "API_KEY_READ_ONLY" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Create or override read-only API key for web UI' >> mailcow.conf
        echo "#API_KEY_READ_ONLY=" >> mailcow.conf
      fi
    elif [[ ${option} == "API_ALLOW_FROM" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Must be set for API_KEY to be active' >> mailcow.conf
        echo '# IPs only, no networks (networks can be set via UI)' >> mailcow.conf
        echo "#API_ALLOW_FROM=" >> mailcow.conf
      fi
    elif [[ ${option} == "SNAT_TO_SOURCE" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Use this IPv4 for outgoing connections (SNAT)' >> mailcow.conf
        echo "#SNAT_TO_SOURCE=" >> mailcow.conf
      fi
    elif [[ ${option} == "SNAT6_TO_SOURCE" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Use this IPv6 for outgoing connections (SNAT)' >> mailcow.conf
        echo "#SNAT6_TO_SOURCE=" >> mailcow.conf
      fi
    elif [[ ${option} == "MAILDIR_GC_TIME" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Garbage collector cleanup' >> mailcow.conf
        echo '# Deleted domains and mailboxes are moved to /var/vmail/_garbage/timestamp_sanitizedstring' >> mailcow.conf
        echo '# How long should objects remain in the garbage until they are being deleted? (value in minutes)' >> mailcow.conf
        echo '# Check interval is hourly' >> mailcow.conf
        echo 'MAILDIR_GC_TIME=1440' >> mailcow.conf
      fi
    elif [[ ${option} == "ACL_ANYONE" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Set this to "allow" to enable the anyone pseudo user. Disabled by default.' >> mailcow.conf
        echo '# When enabled, ACL can be created, that apply to "All authenticated users"' >> mailcow.conf
        echo '# This should probably only be activated on mail hosts, that are used exclusivly by one organisation.' >> mailcow.conf
        echo '# Otherwise a user might share data with too many other users.' >> mailcow.conf
        echo 'ACL_ANYONE=disallow' >> mailcow.conf
      fi
    elif [[ ${option} == "FTS_HEAP" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Dovecot Indexing (FTS) Process maximum heap size in MB, there is no recommendation, please see Dovecot docs.' >> mailcow.conf
        echo '# Flatcurve is used as FTS Engine. It is supposed to be pretty efficient in CPU and RAM consumption.' >> mailcow.conf
        echo '# Please always monitor your Resource consumption!' >> mailcow.conf
        echo "FTS_HEAP=128" >> mailcow.conf
      fi
    elif [[ ${option} == "SKIP_FTS" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Skip FTS (Fulltext Search) for Dovecot on low-memory, low-threaded systems or if you simply want to disable it.' >> mailcow.conf
        echo "# Dovecot inside mailcow use Flatcurve as FTS Backend." >> mailcow.conf
        echo "SKIP_FTS=y" >> mailcow.conf
      fi
    elif [[ ${option} == "FTS_PROCS" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Controls how many processes the Dovecot indexing process can spawn at max.' >> mailcow.conf
        echo '# Too many indexing processes can use a lot of CPU and Disk I/O' >> mailcow.conf
        echo '# Please visit: https://doc.dovecot.org/configuration_manual/service_configuration/#indexer-worker for more informations' >> mailcow.conf
        echo "FTS_PROCS=1" >> mailcow.conf
      fi
    elif [[ ${option} == "ENABLE_SSL_SNI" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Create seperate certificates for all domains - y/n' >> mailcow.conf
        echo '# this will allow adding more than 100 domains, but some email clients will not be able to connect with alternative hostnames' >> mailcow.conf
        echo '# see https://wiki.dovecot.org/SSL/SNIClientSupport' >> mailcow.conf
        echo "ENABLE_SSL_SNI=n" >> mailcow.conf
      fi
    elif [[ ${option} == "SKIP_SOGO" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Skip SOGo: Will disable SOGo integration and therefore webmail, DAV protocols and ActiveSync support (experimental, unsupported, not fully implemented) - y/n' >> mailcow.conf
        echo "SKIP_SOGO=n" >> mailcow.conf
      fi
    elif [[ ${option} == "MAILDIR_SUB" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# MAILDIR_SUB defines a path in a users virtual home to keep the maildir in. Leave empty for updated setups.' >> mailcow.conf
        echo "#MAILDIR_SUB=Maildir" >> mailcow.conf
        echo "MAILDIR_SUB=" >> mailcow.conf
      fi
    elif [[ ${option} == "WATCHDOG_NOTIFY_WEBHOOK" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Send notifications to a webhook URL that receives a POST request with the content type "application/json".' >> mailcow.conf
        echo '# You can use this to send notifications to services like Discord, Slack and others.' >> mailcow.conf
        echo '#WATCHDOG_NOTIFY_WEBHOOK=https://discord.com/api/webhooks/XXXXXXXXXXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' >> mailcow.conf
      fi
    elif [[ ${option} == "WATCHDOG_NOTIFY_WEBHOOK_BODY" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# JSON body included in the webhook POST request. Needs to be in single quotes.' >> mailcow.conf
        echo '# Following variables are available: SUBJECT, BODY' >> mailcow.conf
        WEBHOOK_BODY='{"username": "mailcow Watchdog", "content": "**${SUBJECT}**\n${BODY}"}'
        echo "#WATCHDOG_NOTIFY_WEBHOOK_BODY='${WEBHOOK_BODY}'" >> mailcow.conf
      fi
    elif [[ ${option} == "WATCHDOG_NOTIFY_BAN" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Notify about banned IP. Includes whois lookup.' >> mailcow.conf
        echo "WATCHDOG_NOTIFY_BAN=y" >> mailcow.conf
      fi
    elif [[ ${option} == "WATCHDOG_NOTIFY_START" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Send a notification when the watchdog is started.' >> mailcow.conf
        echo "WATCHDOG_NOTIFY_START=y" >> mailcow.conf
      fi
    elif [[ ${option} == "WATCHDOG_SUBJECT" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Subject for watchdog mails. Defaults to "Watchdog ALERT" followed by the error message.' >> mailcow.conf
        echo "#WATCHDOG_SUBJECT=" >> mailcow.conf
      fi
    elif [[ ${option} == "WATCHDOG_EXTERNAL_CHECKS" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Checks if mailcow is an open relay. Requires a SAL. More checks will follow.' >> mailcow.conf
        echo '# No data is collected. Opt-in and anonymous.' >> mailcow.conf
        echo '# Will only work with unmodified mailcow setups.' >> mailcow.conf
        echo "WATCHDOG_EXTERNAL_CHECKS=n" >> mailcow.conf
      fi
    elif [[ ${option} == "SOGO_EXPIRE_SESSION" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# SOGo session timeout in minutes' >> mailcow.conf
        echo "SOGO_EXPIRE_SESSION=480" >> mailcow.conf
      fi
    elif [[ ${option} == "REDIS_PORT" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo "REDIS_PORT=127.0.0.1:7654" >> mailcow.conf
      fi
    elif [[ ${option} == "DOVECOT_MASTER_USER" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# DOVECOT_MASTER_USER and _PASS must _both_ be provided. No special chars.' >> mailcow.conf
        echo '# Empty by default to auto-generate master user and password on start.' >> mailcow.conf
        echo '# User expands to DOVECOT_MASTER_USER@mailcow.local' >> mailcow.conf
        echo '# LEAVE EMPTY IF UNSURE' >> mailcow.conf
        echo "DOVECOT_MASTER_USER=" >> mailcow.conf
      fi
    elif [[ ${option} == "DOVECOT_MASTER_PASS" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# LEAVE EMPTY IF UNSURE' >> mailcow.conf
        echo "DOVECOT_MASTER_PASS=" >> mailcow.conf
      fi
    elif [[ ${option} == "MAILCOW_PASS_SCHEME" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Password hash algorithm' >> mailcow.conf
        echo '# Only certain password hash algorithm are supported. For a fully list of supported schemes,' >> mailcow.conf
        echo '# see https://docs.mailcow.email/models/model-passwd/' >> mailcow.conf
        echo "MAILCOW_PASS_SCHEME=BLF-CRYPT" >> mailcow.conf
      fi
    elif [[ ${option} == "ADDITIONAL_SERVER_NAMES" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Additional server names for mailcow UI' >> mailcow.conf
        echo '#' >> mailcow.conf
        echo '# Specify alternative addresses for the mailcow UI to respond to' >> mailcow.conf
        echo '# This is useful when you set mail.* as ADDITIONAL_SAN and want to make sure mail.maildomain.com will always point to the mailcow UI.' >> mailcow.conf
        echo '# If the server name does not match a known site, Nginx decides by best-guess and may redirect users to the wrong web root.' >> mailcow.conf
        echo '# You can understand this as server_name directive in Nginx.' >> mailcow.conf
        echo '# Comma separated list without spaces! Example: ADDITIONAL_SERVER_NAMES=a.b.c,d.e.f' >> mailcow.conf
        echo 'ADDITIONAL_SERVER_NAMES=' >> mailcow.conf
      fi
    elif [[ ${option} == "ACME_CONTACT" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Lets Encrypt registration contact information' >> mailcow.conf
        echo '# Optional: Leave empty for none' >> mailcow.conf
        echo '# This value is only used on first order!' >> mailcow.conf
        echo '# Setting it at a later point will require the following steps:' >> mailcow.conf
        echo '# https://docs.mailcow.email/troubleshooting/debug-reset_tls/' >> mailcow.conf
        echo 'ACME_CONTACT=' >> mailcow.conf
      fi
    elif [[ ${option} == "WEBAUTHN_ONLY_TRUSTED_VENDORS" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo "# WebAuthn device manufacturer verification" >> mailcow.conf
        echo '# After setting WEBAUTHN_ONLY_TRUSTED_VENDORS=y only devices from trusted manufacturers are allowed' >> mailcow.conf
        echo '# root certificates can be placed for validation under mailcow-dockerized/data/web/inc/lib/WebAuthn/rootCertificates' >> mailcow.conf
        echo 'WEBAUTHN_ONLY_TRUSTED_VENDORS=n' >> mailcow.conf
      fi
    elif [[ ${option} == "SPAMHAUS_DQS_KEY" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo "# Spamhaus Data Query Service Key" >> mailcow.conf
        echo '# Optional: Leave empty for none' >> mailcow.conf
        echo '# Enter your key here if you are using a blocked ASN (OVH, AWS, Cloudflare e.g) for the unregistered Spamhaus Blocklist.' >> mailcow.conf
        echo '# If empty, it will completely disable Spamhaus blocklists if it detects that you are running on a server using a blocked AS.' >> mailcow.conf
        echo '# Otherwise it will work as usual.' >> mailcow.conf
        echo 'SPAMHAUS_DQS_KEY=' >> mailcow.conf
      fi
    elif [[ ${option} == "WATCHDOG_VERBOSE" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Enable watchdog verbose logging' >> mailcow.conf
        echo 'WATCHDOG_VERBOSE=n' >> mailcow.conf
      fi
    elif [[ ${option} == "SKIP_UNBOUND_HEALTHCHECK" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Skip Unbound (DNS Resolver) Healthchecks (NOT Recommended!) - y/n' >> mailcow.conf
        echo 'SKIP_UNBOUND_HEALTHCHECK=n' >> mailcow.conf
      fi
    elif [[ ${option} == "DISABLE_NETFILTER_ISOLATION_RULE" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Prevent netfilter from setting an iptables/nftables rule to isolate the mailcow docker network - y/n' >> mailcow.conf
        echo '# CAUTION: Disabling this may expose container ports to other neighbors on the same subnet, even if the ports are bound to localhost' >> mailcow.conf
        echo 'DISABLE_NETFILTER_ISOLATION_RULE=n' >> mailcow.conf
      fi
    elif [[ ${option} == "HTTP_REDIRECT" ]]; then
      if ! grep -q ${option} mailcow.conf; then
        echo "Adding new option \"${option}\" to mailcow.conf"
        echo '# Redirect HTTP connections to HTTPS - y/n' >> mailcow.conf
        echo 'HTTP_REDIRECT=n' >> mailcow.conf
      fi
    elif ! grep -q ${option} mailcow.conf; then
      echo "Adding new option \"${option}\" to mailcow.conf"
      echo "${option}=n" >> mailcow.conf
    fi
  done
}