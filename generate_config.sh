#!/usr/bin/env bash

set -o pipefail

error_exit(){
  echo -e "\e[31mERROR: $1\e[0m" >&2
  exit 1
}

# Import of check scripts
source .scripts/checks/host_checks.sh 2>/dev/null || error_exit "Could not load .scripts/checks/host_checks.sh! Make sure you run this script from mailcow Root directory"
source .scripts/checks/docker_checks.sh 2>/dev/null || error_exit "Could not load .scripts/checks/docker_checks.sh! Make sure you run this script from mailcow Root directory"
source .scripts/checks/asn_checks.sh 2>/dev/null || error_exit "Could not load .scripts/checks/asn_checks.sh! Make sure you run this script from mailcow Root directory"

# Import of action scripts
source .scripts/actions/ipv6_controller.sh || error_exit "Could not load .scripts/actions/ipv6_controller.sh! Make sure you run this script from mailcow Root directory"

# Run online status check from .scripts/checks/host_checks.sh
check_online_status

# Run kernel check from .scripts/checks/host_checks.sh
kernel_checks

# Run package requirement for using mailcow from from .scripts/checks/host_checks.sh
package_checks

# Running Docker Version and Docker Compose Version checks to run mailcow from .scripts/checks/docker_checks.sh
check_docker_version
detect_docker_compose_command

### If generate_config.sh is started with --dev or -d it will not check out nightly or master branch and will keep on the current branch
if [[ ${1} == "--dev" || ${1} == "-d" ]]; then
  SKIP_BRANCH=y
else
  SKIP_BRANCH=n
fi

if [ -f mailcow.conf ]; then
  read -r -p "A config file exists and will be overwritten, are you sure you want to continue? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv mailcow.conf mailcow.conf_backup
      chmod 600 mailcow.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

echo "Press enter to confirm the detected value '[value]' where applicable or enter a custom value."
while [ -z "${MAILCOW_HOSTNAME}" ]; do
  read -p "Mail server hostname (FQDN) - this is not your mail domain, but your mail servers hostname: " MAILCOW_HOSTNAME; export MAILCOW_HOSTNAME
  DOTS=${MAILCOW_HOSTNAME//[^.]};
  if [ ${#DOTS} -lt 1 ]; then
    echo -e "\e[31mMAILCOW_HOSTNAME (${MAILCOW_HOSTNAME}) is not a FQDN!\e[0m"
    sleep 1
    echo "Please change it to a FQDN and redeploy the stack with docker(-)compose up -d"
    exit 1
  elif [[ "${MAILCOW_HOSTNAME: -1}" == "." ]]; then
    echo "MAILCOW_HOSTNAME (${MAILCOW_HOSTNAME}) is ending with a dot. This is not a valid FQDN!"
    exit 1
  elif [ ${#DOTS} -eq 1 ]; then
    echo -e "\e[33mMAILCOW_HOSTNAME (${MAILCOW_HOSTNAME}) does not contain a Subdomain. This is not fully tested and may cause issues.\e[0m"
    echo "Find more information about why this message exists here: https://github.com/mailcow/mailcow-dockerized/issues/1572"
    read -r -p "Do you want to proceed anyway? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
      echo "OK. Procceding."
    else
      echo "OK. Exiting."
      exit 1
    fi
  fi
done

if [ -a /etc/timezone ]; then
  DETECTED_TZ=$(cat /etc/timezone)
elif [ -a /etc/localtime ]; then
  DETECTED_TZ=$(readlink /etc/localtime|sed -n 's|^.*zoneinfo/||p')
fi

while [ -z "${MAILCOW_TZ}" ]; do
  if [ -z "${DETECTED_TZ}" ]; then
    read -p "Timezone: " -e MAILCOW_TZ
  else
    read -p "Timezone [${DETECTED_TZ}]: " MAILCOW_TZ; export MAILCOW_TZ
    [ -z "${MAILCOW_TZ}" ] && MAILCOW_TZ=${DETECTED_TZ}
  fi
done

MEM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)

if [ -z "${SKIP_CLAMD}" ]; then
  if [ "${MEM_TOTAL}" -le "2621440" ]; then
    echo "Installed memory is <= 2.5 GiB. It is recommended to disable ClamAV to prevent out-of-memory situations."
    echo "ClamAV can be re-enabled by setting SKIP_CLAMD=n in mailcow.conf."
    read -r -p  "Do you want to disable ClamAV now? [Y/n] " response
    case $response in
      [nN][oO]|[nN])
        export SKIP_CLAMD=n
        ;;
      *)
        export SKIP_CLAMD=y
      ;;
    esac
  else
    export SKIP_CLAMD=n
  fi
fi

if [[ ${SKIP_BRANCH} != y ]]; then
  echo "Which branch of mailcow do you want to use?"
  echo ""
  echo "Available Branches:"
  echo "- master branch (stable updates) | default, recommended [1]"
  echo "- nightly branch (unstable updates, testing) | not-production ready [2]"
  sleep 1

  while [ -z "${MAILCOW_BRANCH}" ]; do
    read -r -p  "Choose the Branch with it's number [1/2] " branch
    case $branch in
      [2])
        MAILCOW_BRANCH="nightly"
        ;;
      *)
        MAILCOW_BRANCH="master"
      ;;
    esac
  done

  git fetch --all
  git checkout -f "$MAILCOW_BRANCH"

elif [[ ${SKIP_BRANCH} == y ]]; then
  echo -e "\033[33mEnabled Dev Mode.\033[0m"
  echo -e "\033[33mNot checking out a different branch!\033[0m"
  MAILCOW_BRANCH=$(git rev-parse --short $(git rev-parse @{upstream}))

else
  echo -e "\033[31mCould not determine branch input..."
  echo -e "\033[31mExiting."
  exit 1
fi

if [ ! -z "${MAILCOW_BRANCH}" ]; then
  git_branch=${MAILCOW_BRANCH}
fi

[ ! -f ./data/conf/rspamd/override.d/worker-controller-password.inc ] && echo '# Placeholder' > ./data/conf/rspamd/override.d/worker-controller-password.inc

mkdir -p data/assets/ssl

export DBPASS=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
export DBROOT=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
export REDISPASS=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)

# Create fresh mailcow.conf from template
envsubst < .scripts/actions/fresh-install/mailcow-conf.template > mailcow.conf

chmod 600 mailcow.conf

# Make sure .env is linking to mailcow.conf

if ! [[ -L .env && "$(readlink .env)" == "mailcow.conf" ]]; then
  echo "Your .env is currently not a link to mailcow.conf... fixing this"
  rm -rf .env
  ln -s mailcow.conf .env
fi

# copy but don't overwrite existing certificate
echo "Generating snake-oil certificate..."
# Making Willich more popular
openssl req -x509 -newkey rsa:4096 -keyout data/assets/ssl-example/key.pem -out data/assets/ssl-example/cert.pem -days 365 -subj "/C=DE/ST=NRW/L=Willich/O=mailcow/OU=mailcow/CN=${MAILCOW_HOSTNAME}" -sha256 -nodes
echo "Copying snake-oil certificate..."
cp -n -d data/assets/ssl-example/*.pem data/assets/ssl/

# Set app_info.inc.php
case ${git_branch} in
  master)
    mailcow_git_version=$(git describe --tags `git rev-list --tags --max-count=1`)
    ;;
  nightly)
    mailcow_git_version=$(git rev-parse --short $(git rev-parse @{upstream}))
    mailcow_last_git_version=""
    ;;
  *)
    mailcow_git_version=$(git rev-parse --short HEAD)
    mailcow_last_git_version=""
    ;;
esac

if [[ $SKIP_BRANCH != "y" ]]; then
  mailcow_git_commit=$(git rev-parse origin/${git_branch})
  mailcow_git_commit_date=$(git log -1 --format=%ci @{upstream} )
else
  mailcow_git_commit=$(git rev-parse ${git_branch})
  mailcow_git_commit_date=$(git log -1 --format=%ci @{upstream} )
  git_branch=$(git rev-parse --abbrev-ref HEAD)
fi

if [ $? -eq 0 ]; then
  echo '<?php' > data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_VERSION="'$mailcow_git_version'";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_LAST_GIT_VERSION="";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_OWNER="mailcow";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_REPO="mailcow-dockerized";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_URL="https://github.com/mailcow/mailcow-dockerized";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_COMMIT="'$mailcow_git_commit'";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_COMMIT_DATE="'$mailcow_git_commit_date'";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_BRANCH="'$git_branch'";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_UPDATEDAT='$(date +%s)';' >> data/web/inc/app_info.inc.php
  echo '?>' >> data/web/inc/app_info.inc.php
else
  echo '<?php' > data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_VERSION="'$mailcow_git_version'";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_LAST_GIT_VERSION="";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_OWNER="mailcow";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_REPO="mailcow-dockerized";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_URL="https://github.com/mailcow/mailcow-dockerized";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_COMMIT="";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_GIT_COMMIT_DATE="";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_BRANCH="'$git_branch'";' >> data/web/inc/app_info.inc.php
  echo '  $MAILCOW_UPDATEDAT='$(date +%s)';' >> data/web/inc/app_info.inc.php
  echo '?>' >> data/web/inc/app_info.inc.php
  echo -e "\e[33mCannot determine current git repository version...\e[0m"
fi