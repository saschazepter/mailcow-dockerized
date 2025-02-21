#!/bin/bash

detect_bad_asn() {
  echo -e "\e[33mDetecting if your IP is listed on Spamhaus Bad ASN List...\e[0m"
  response=$(curl --connect-timeout 15 --max-time 30 -s -o /dev/null -w "%{http_code}" "https://asn-check.mailcow.email")
  if [ "$response" -eq 503 ]; then
    if [ -z "$SPAMHAUS_DQS_KEY" ]; then
      echo -e "\e[33mYour server's public IP uses an AS that is blocked by Spamhaus to use their DNS public blocklists for Postfix.\e[0m"
      echo -e "\e[33mmailcow did not detected a value for the variable SPAMHAUS_DQS_KEY inside mailcow.conf!\e[0m"
      sleep 2
      echo ""
      echo -e "\e[33mTo use the Spamhaus DNS Blocklists again, you will need to create a FREE account for their Data Query Service (DQS) at: https://www.spamhaus.com/free-trial/sign-up-for-a-free-data-query-service-account\e[0m"
      echo -e "\e[33mOnce done, enter your DQS API key in mailcow.conf and mailcow will do the rest for you!\e[0m"
      echo ""
      sleep 2

    else
      echo -e "\e[33mYour server's public IP uses an AS that is blocked by Spamhaus to use their DNS public blocklists for Postfix.\e[0m"
      echo -e "\e[32mmailcow detected a Value for the variable SPAMHAUS_DQS_KEY inside mailcow.conf. Postfix will use DQS with the given API key...\e[0m"
    fi
  elif [ "$response" -eq 200 ]; then
    echo -e "\e[33mCheck completed! Your IP is \e[32mclean\e[0m"
  elif [ "$response" -eq 429 ]; then
    echo -e "\e[33mCheck completed! \e[31mYour IP seems to be rate limited on the ASN Check service... please try again later!\e[0m"
  else
    echo -e "\e[31mCheck failed! \e[0mMaybe a DNS or Network problem?\e[0m"
  fi
}