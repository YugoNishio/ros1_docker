# If not working, first do: sudo rm -rf /tmp/.docker.xauth
# It still not working, try running the script as root.

xhost +
XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

docker run -p 6080:80 -p 10000:10000 -p 5005:5005 \
    -v /dev:/dev --shm-size=512m \
    -v $PWD/docker_share:/home/hosts_files --privileged \
    -it \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --name="harvesting_robot" \
    harvesting_robot \
    bash

echo "done"
