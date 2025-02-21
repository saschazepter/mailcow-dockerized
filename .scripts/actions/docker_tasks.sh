#!/bin/bash

prefetch_images() {
  [[ -z ${BRANCH} ]] && { echo -e "\e[33m\nUnknown branch...\e[0m"; exit 1; }
  git fetch origin #${BRANCH}
  while read image; do
    if [[ "${image}" == "robbertkl/ipv6nat" ]]; then
      if ! grep -qi "ipv6nat-mailcow" docker-compose.yml || grep -qi "enable_ipv6: false" docker-compose.yml; then
        continue
      fi
    fi
    RET_C=0
    until docker pull "${image}"; do
      RET_C=$((RET_C + 1))
      echo -e "\e[33m\nError pulling $image, retrying...\e[0m"
      [ ${RET_C} -gt 3 ] && { echo -e "\e[31m\nToo many failed retries, exiting\e[0m"; exit 1; }
      sleep 1
    done
  done < <(git show "origin/${BRANCH}:docker-compose.yml" | grep "image:" | awk '{ gsub("image:","", $3); print $2 }')
}

docker_garbage() {
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  IMGS_TO_DELETE=()

  declare -A IMAGES_INFO
  COMPOSE_IMAGES=($(grep -oP "image: \Kmailcow.+" "${SCRIPT_DIR}/docker-compose.yml"))

  for existing_image in $(docker images --format "{{.ID}}:{{.Repository}}:{{.Tag}}" | grep 'mailcow/'); do
      ID=$(echo "$existing_image" | cut -d ':' -f 1)
      REPOSITORY=$(echo "$existing_image" | cut -d ':' -f 2)
      TAG=$(echo "$existing_image" | cut -d ':' -f 3)

      if [[ " ${COMPOSE_IMAGES[@]} " =~ " ${REPOSITORY}:${TAG} " ]]; then
          continue
      else
          IMGS_TO_DELETE+=("$ID")
          IMAGES_INFO["$ID"]="$REPOSITORY:$TAG"
      fi
  done

  if [[ ! -z ${IMGS_TO_DELETE[*]} ]]; then
      echo "The following unused mailcow images were found:"
      for id in "${IMGS_TO_DELETE[@]}"; do
          echo "    ${IMAGES_INFO[$id]} ($id)"
      done

      if [ ! $FORCE ]; then
          read -r -p "Do you want to delete them to free up some space? [y/N] " response
          if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
              docker rmi ${IMGS_TO_DELETE[*]}
          else
              echo "OK, skipped."
          fi
      else
          echo "Running in forced mode! Force removing old mailcow images..."
          docker rmi ${IMGS_TO_DELETE[*]}
      fi
      echo -e "\e[32mFurther cleanup...\e[0m"
      echo "If you want to cleanup further garbage collected by Docker, please make sure all containers are up and running before cleaning your system by executing \"docker system prune\""
  fi
}