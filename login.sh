#!/bin/bash
DOCKER_CONTAINER="harvesting_robot_humble"

eval xhost local:root
eval docker start "$DOCKER_CONTAINER"
eval docker attach "$DOCKER_CONTAINER"
