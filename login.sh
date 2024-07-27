#!/bin/bash
DOCKER_CONTAINER="harvesting_robot"

eval xhost local:root
eval docker start "$DOCKER_CONTAINER"
eval docker attach "$DOCKER_CONTAINER"
eval export LIBGL_ALWAYS_SOFTWARE=1