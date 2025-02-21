#!/bin/bash
# ipv6_controller.sh – Central IPv6 control script
# This script controls mailcow's usage of IPv6 and will adjust the Docker daemon.json file accordingly
# It is meant to be a drop in replacement of the previous function migrate_docker_nat to streamline the IPv6 handling for mailcow
# THIS SCRIPT IS INTENDED TO BE USED BY INTERNAL MAILCOW SCRIPTS. DO NOT TRY RUNNING THIS STANDALONE!!

# DEBUG/TESTING PARAMETERS WILL USUALLY HANDED BY THE MAIN SCRIPTS
# MAILCOW_CONF="/opt/mailcow-dockerized/mailcow.conf"
# DAEMON_EXPERIMENTAL="true"

configure_ipv6() {
     if grep -q '^ENABLE_IPv6=false' "$MAILCOW_CONF"; then
          echo "IPv6 has been strictly disabled inside mailcow.conf using ENABLE_IPv6=false. Skipping further IPv6 checks..."
          return 0
     else
          echo "Checking IPv6 connectivity..."
          if ping6 -c 3 -W 2 google.com >/dev/null 2>&1; then
               echo "Host is capable of IPv6!"
               ipv6_available=true
          else
               echo "Host is not capable of IPv6..."
               ipv6_available=false
               if grep -q '^ENABLE_IPv6=' "$MAILCOW_CONF"; then
                    sed -i 's/^ENABLE_IPv6=.*/ENABLE_IPv6=false/' "$MAILCOW_CONF"
               else
                    printf "\nENABLE_IPv6=false\n" >> "$MAILCOW_CONF"
               fi
               echo "Disabled IPv6 for you by setting ENABLE_IPv6=false in mailcow.conf"
          fi
     fi

     # 2. Only if IPv6 is available, update the Docker daemon configuration
     if [ "$ipv6_available" = true ]; then
          DAEMON_CONFIG="/etc/docker/daemon.json"

          if [ "$DAEMON_EXPERIMENTAL" = "true" ]; then
               REQUIRED_OPTIONS='{
               "ipv6": true,
               "experimental": true,
               "fixed-cidr-v6": "fd00:dead:beef:c0::/80",
               "ip6tables": true
               }'
          else
               REQUIRED_OPTIONS='{
               "ipv6": true,
               "fixed-cidr-v6": "fd00:dead:beef:c0::/80",
               "ip6tables": true
               }'
          fi

     else
          echo "IPv6 is not available; Docker daemon configuration will not be modified."
          return 0
     fi

     if [ -f "$DAEMON_CONFIG" ]; then
          echo "Checking daemon.json for required IPv6 keys..."
          has_ipv6=$(jq 'has("ipv6")' "$DAEMON_CONFIG")
          has_fixed=$(jq 'has("fixed-cidr-v6")' "$DAEMON_CONFIG")
          has_ip6tables=$(jq 'has("ip6tables")' "$DAEMON_CONFIG")
          has_experimental=$(jq 'has("experimental")' "$DAEMON_CONFIG")

          if [ "$has_ipv6" = "true" ] && [ "$has_fixed" = "true" ] && [ "$has_ip6tables" = "true" ]; then
               if [ "$DAEMON_EXPERIMENTAL" = "true" ]; then
                    if [ "$has_experimental" = "true" ]; then
                         echo "Docker daemon.json already contain all necessary options for native IPv6 NAT depending your current installed Docker version."
                         echo "NO changes needed!"
                    else
                         echo "Docker daemon.json is missing 'experimental' value! Adjust daemon.json..."
                         updated=$(jq -s '.[0] * .[1]' "$DAEMON_CONFIG" <(echo "$REQUIRED_OPTIONS"))
                         echo "$updated" > "$DAEMON_CONFIG"
                         echo "Docker daemon.json has been modified. Try restarting docker...."
                         if ! systemctl restart docker; then
                              echo "Oh no! It seems Docker was not able to restart..."
                              echo "Your daemon.json seems to be corrupted. Make sure it's in a valid json Format before restarting docker again..."
                              echo "Please recheck your daemon.json again and make sure to adapt the following snippet:"
                              echo "$REQUIRED_OPTIONS"
                              exit 1
                         fi
                    fi
               else
                    if [ "$has_experimental" = "true" ]; then
                         echo "'experimental' Key found but is not needed for Docker versions starting 27.X... Adjusting daemon.json..."
                         # Entferne explizit den experimental key
                         temp=$(jq 'del(.experimental)' "$DAEMON_CONFIG")
                         # Merge mit REQUIRED_OPTIONS (die keinen 'experimental'-Schlüssel beinhalten)
                         updated=$(jq -s '.[0] * .[1]' <(echo "$temp") <(echo "$REQUIRED_OPTIONS"))
                         echo "$updated" > "$DAEMON_CONFIG"
                         echo "Docker daemon.json has been modified. Try restarting docker...."
                         if ! systemctl restart docker; then
                              echo "Oh no! It seems Docker was not able to restart..."
                              echo "Your daemon.json seems to be corrupted. Make sure it's in a valid json Format before restarting docker again..."
                              echo "Please recheck your daemon.json again and make sure to adapt the following snippet:"
                              echo "$REQUIRED_OPTIONS"
                              exit 1
                         fi
                    else
                         echo "Docker daemon.json already using the correct parameters to allow native IPv6 NAT"
                         echo "No changes needed..."
                    fi
               fi
          else
               echo "Docker daemon.json is missing necessary IPv6 JSON keys to operate properly... Adjusting daemon.json..."
               updated=$(jq -s '.[0] * .[1]' "$DAEMON_CONFIG" <(echo "$REQUIRED_OPTIONS"))
               echo "$updated" > "$DAEMON_CONFIG"
               echo "Docker daemon.json has been modified. Try restarting docker...."
               if ! systemctl restart docker; then
                    echo "Oh no! It seems Docker was not able to restart..."
                    echo "Your daemon.json seems to be corrupted. Make sure it's in a valid json Format before restarting docker again..."
                    echo "Please recheck your daemon.json again and make sure to adapt the following snippet:"
                    echo "$REQUIRED_OPTIONS"
                    exit 1
               fi
          fi
     else
          echo "Docker daemon.json does not exist yet. Creating a fresh version in order to make native IPv6 NAT working..."
          echo "$REQUIRED_OPTIONS" > "$DAEMON_CONFIG"
          echo "Docker daemon.json has been modified. Try restarting docker...."
          if ! systemctl restart docker; then
               echo "Oh no! It seems Docker was not able to restart..."
               echo "Your daemon.json seems to be corrupted. Make sure it's in a valid json Format before restarting docker again..."
               echo "Please recheck your daemon.json again and make sure to adapt the following snippet:"
               echo "$REQUIRED_OPTIONS"
               exit 1
          fi
     fi

}

# DEBUG | CALLS FUNCTION STANDALONE (ONLY RECOMMENDED FOR SINGLE SCRIPT DEBUGGING) 
# configure_ipv6