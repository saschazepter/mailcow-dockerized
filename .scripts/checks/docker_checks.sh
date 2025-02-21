# !/bin/bash

check_docker_version() {
  local version=$(docker -v | grep -oP '\d+\.\d+' | head -n 1)
  local major_version=${version%%.*}
  if [[ "$major_version" -lt 24 ]]; then
    echo "Docker version 24.x or higher is required."
    exit 1
  elif [[ "$major_version" -ge 24  &&  "$major_version" -lt 27 ]]; then
    DAEMON_EXPERIMENTAL=true
  else
    DAEMON_EXPERIMENTAL=false
  fi
}

check_docker_compose() {
  if docker compose > /dev/null 2>&1; then
    echo "Docker Compose Plugin detected."
    COMPOSE_VERSION=native
  elif docker-compose > /dev/null 2>&1; then
    echo "Standalone Docker Compose detected."
    COMPOSE_VERSION=standalone
  else
    echo "Docker Compose not found. Please install it."
    exit 1
  fi
}

detect_docker_compose_command(){
if ! [[ "${DOCKER_COMPOSE_VERSION}" =~ ^(native|standalone)$ ]]; then
  if docker compose > /dev/null 2>&1; then
      if docker compose version --short | grep -e "^2." -e "^v2." > /dev/null 2>&1; then
        DOCKER_COMPOSE_VERSION=native
        COMPOSE_COMMAND="docker compose"
        echo -e "\e[33mFound Docker Compose Plugin (native).\e[0m"
        echo -e "\e[33mSetting the DOCKER_COMPOSE_VERSION Variable to native\e[0m"
        sed -i 's/^DOCKER_COMPOSE_VERSION=.*/DOCKER_COMPOSE_VERSION=native/' "$SCRIPT_DIR/mailcow.conf"
        sleep 2
        echo -e "\e[33mNotice: You'll have to update this Compose Version via your Package Manager manually!\e[0m"
      else
        echo -e "\e[31mCannot find Docker Compose with a Version Higher than 2.X.X.\e[0m"
        echo -e "\e[31mPlease update/install it manually regarding to this doc site: https://docs.mailcow.email/install/\e[0m"
        exit 1
      fi
  elif docker-compose > /dev/null 2>&1; then
    if ! [[ $(alias docker-compose 2> /dev/null) ]] ; then
      if docker-compose version --short | grep "^2." > /dev/null 2>&1; then
        DOCKER_COMPOSE_VERSION=standalone
        COMPOSE_COMMAND="docker-compose"
        echo -e "\e[33mFound Docker Compose Standalone.\e[0m"
        echo -e "\e[33mSetting the DOCKER_COMPOSE_VERSION Variable to standalone\e[0m"
        sed -i 's/^DOCKER_COMPOSE_VERSION=.*/DOCKER_COMPOSE_VERSION=standalone/' "$SCRIPT_DIR/mailcow.conf"
        sleep 2
        echo -e "\e[33mNotice: For an automatic update of docker-compose please use the update_compose.sh scripts located at the helper-scripts folder.\e[0m"
      else
        echo -e "\e[31mCannot find Docker Compose with a Version Higher than 2.X.X.\e[0m"
        echo -e "\e[31mPlease update/install regarding to this doc site: https://docs.mailcow.email/install/\e[0m"
        exit 1
      fi
    fi

  else
    echo -e "\e[31mCannot find Docker Compose.\e[0m"
    echo -e "\e[31mPlease install it regarding to this doc site: https://docs.mailcow.email/install/\e[0m"
    exit 1
  fi

elif [ "${DOCKER_COMPOSE_VERSION}" == "native" ]; then
  COMPOSE_COMMAND="docker compose"
  # Check if Native Compose works and has not been deleted
  if ! $COMPOSE_COMMAND > /dev/null 2>&1; then
    # IF it not exists/work anymore try the other command
    COMPOSE_COMMAND="docker-compose"
    if ! $COMPOSE_COMMAND > /dev/null 2>&1 || ! $COMPOSE_COMMAND --version | grep "^2." > /dev/null 2>&1; then
      # IF it cannot find Standalone in > 2.X, then script stops
      echo -e "\e[31mCannot find Docker Compose or the Version is lower then 2.X.X.\e[0m"
      echo -e "\e[31mPlease install it regarding to this doc site: https://docs.mailcow.email/install/\e[0m"
      exit 1
    fi
      # If it finds the standalone Plugin it will use this instead and change the mailcow.conf Variable accordingly
      echo -e "\e[31mFound different Docker Compose Version then declared in mailcow.conf!\e[0m"
      echo -e "\e[31mSetting the DOCKER_COMPOSE_VERSION Variable from native to standalone\e[0m"
      sed -i 's/^DOCKER_COMPOSE_VERSION=.*/DOCKER_COMPOSE_VERSION=standalone/' "$SCRIPT_DIR/mailcow.conf"
      sleep 2
  fi


elif [ "${DOCKER_COMPOSE_VERSION}" == "standalone" ]; then
  COMPOSE_COMMAND="docker-compose"
  # Check if Standalone Compose works and has not been deleted
  if ! $COMPOSE_COMMAND > /dev/null 2>&1 && ! $COMPOSE_COMMAND --version > /dev/null 2>&1 | grep "^2." > /dev/null 2>&1; then
    # IF it not exists/work anymore try the other command
    COMPOSE_COMMAND="docker compose"
    if ! $COMPOSE_COMMAND > /dev/null 2>&1; then
      # IF it cannot find Native in > 2.X, then script stops
      echo -e "\e[31mCannot find Docker Compose.\e[0m"
      echo -e "\e[31mPlease install it regarding to this doc site: https://docs.mailcow.email/install/\e[0m"
      exit 1
    fi
      # If it finds the native Plugin it will use this instead and change the mailcow.conf Variable accordingly
      echo -e "\e[31mFound different Docker Compose Version then declared in mailcow.conf!\e[0m"
      echo -e "\e[31mSetting the DOCKER_COMPOSE_VERSION Variable from standalone to native\e[0m"
      sed -i 's/^DOCKER_COMPOSE_VERSION=.*/DOCKER_COMPOSE_VERSION=native/' "$SCRIPT_DIR/mailcow.conf"
      sleep 2
  fi
fi
}