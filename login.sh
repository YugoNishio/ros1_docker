#!/bin/bash
DOCKER_CONTAINER="crane_x7_robot"

eval xhost local:root
eval docker start "$DOCKER_CONTAINER"
eval docker attach "$DOCKER_CONTAINER"
eval export LIBGL_ALWAYS_SOFTWARE=1