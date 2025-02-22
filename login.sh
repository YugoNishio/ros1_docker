#!/bin/bash
DOCKER_CONTAINER="harvesting_robot_play_ground"

eval xhost local:root
eval docker start "$DOCKER_CONTAINER"
eval docker attach "$DOCKER_CONTAINER"
