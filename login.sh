#!/bin/bash
DOCKER_CONTAINER="harvesting_robot"

eval xhost local:root
eval docker start "$DOCKER_CONTAINER"
eval docker attach "$DOCKER_CONTAINER"
#eval "docker container exec -it "$DOCKER_CONTAINER" bash"