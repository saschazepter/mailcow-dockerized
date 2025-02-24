#!/bin/bash

check_online_status() {
  CHECK_ONLINE_DOMAINS=('https://github.com' 'https://hub.docker.com')
  for domain in "${CHECK_ONLINE_DOMAINS[@]}"; do
    if timeout 6 curl --head --silent --output /dev/null ${domain}; then
      return 0
    fi
  done
  return 1
}

kernel_checks(){
    if [[ "$(uname -r)" =~ ^4\.15\.0-60 ]]; then
    echo "DO NOT RUN mailcow ON THIS UBUNTU KERNEL!";
    echo "Please update to 5.x or use another distribution."
    exit 1
    fi

    if [[ "$(uname -r)" =~ ^4\.4\. ]]; then
    if grep -q Ubuntu <<< "$(uname -a)"; then
        echo "DO NOT RUN mailcow ON THIS UBUNTU KERNEL!"
        echo "Please update to linux-generic-hwe-16.04 by running \"apt-get install --install-recommends linux-generic-hwe-16.04\""
        exit 1
    fi
    echo "mailcow on a 4.4.x kernel is not supported. It may or may not work, please upgrade your kernel or continue at your own risk."
    read -p "Press any key to continue..." < /dev/tty
    fi
}

package_checks(){
    for bin in curl docker git awk sha1sum grep cut jq readlink ; do
        if [[ -z $(command -v ${bin}) ]]; then
        echo "Cannot find ${bin}, exiting..."
        exit 1;
        fi
    done

    if grep --help 2>&1 | head -n 1 | grep -q -i "busybox"; then echo "BusyBox grep detected, please install gnu grep, \"apk add --no-cache --upgrade grep\""; exit 1; fi
    # This will also cover sort
    if cp --help 2>&1 | head -n 1 | grep -q -i "busybox"; then echo "BusyBox cp detected, please install coreutils, \"apk add --no-cache --upgrade coreutils\""; exit 1; fi
    if sed --help 2>&1 | head -n 1 | grep -q -i "busybox"; then echo "BusyBox sed detected, please install gnu sed, \"apk add --no-cache --upgrade sed\""; exit 1; fi
}

check_mailcowconf(){
    if [[ ! -f mailcow.conf ]]; then
        echo -e "\e[31mmailcow.conf is missing! Is mailcow installed?\e[0m"
        exit 1
    fi
}