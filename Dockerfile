FROM osrf/ros:noetic-desktop-full

WORKDIR /home
ENV HOME /home

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Tokyo

ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

# install vim
RUN apt-get update -qq
RUN apt-get install -y tzdata
RUN apt-get update && apt-get install -y vim git lsb-release sudo gnupg tmux curl

# install terminator
RUN apt-get install -y terminator

RUN apt-get install -y ros-noetic-rqt-* 
RUN apt-get install -y python3-catkin-tools
RUN apt-get install -y ros-noetic-ros-control ros-noetic-ros-controllers
RUN apt-get install -y ros-noetic-rviz
RUN apt-get install -y ros-noetic-rviz-visual-tools
RUN apt-get install -y ros-noetic-moveit-visual-tools
RUN apt-get install -y ros-noetic-moveit ros-noetic-moveit-planners-ompl
RUN apt-get install -y ros-noetic-control*
RUN apt-get install -y ros-noetic-rosbridge-suite
RUN apt-get install -y ros-noetic-openni-launch
RUN apt-get install -y libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
# install smach
RUN apt-get install -y ros-noetic-smach-ros ros-noetic-smach-viewer

# set catkin workspace
COPY config/git_clone.sh /home/git_clone.sh
RUN echo "source /opt/ros/noetic/setup.sh" >> .bashrc
RUN mkdir -p catkin_ws/src
RUN cd catkin_ws/src && . /opt/ros/noetic/setup.sh && catkin_init_workspace
RUN cd && cd catkin_ws && . /opt/ros/noetic/setup.sh && catkin_make
RUN echo "source ./catkin_ws/devel/setup.bash" >> .bashrc

COPY config/.bashrc /home/.bashrc
COPY config/.vimrc /home/.vimrc

# clean workspace
RUN rm -rf git_clone.sh

# install universal_robot package
RUN cd /home/catkin_ws/src && git clone https://github.com/rt-net/crane_x7_ros.git
RUN cd /home/catkin_ws/src && git clone https://github.com/roboticsgroup/roboticsgroup_gazebo_plugins.git
RUN cd /home/catkin_ws/src && git clone https://github.com/rt-net/crane_x7_description.git
RUN rosdep update
RUN cd /home/catkin_ws/src && rosdep install -r -y --from-paths . --ignore-src

# remove opencv4
RUN rm -r /usr/lib/x86_64-linux-gnu/cmake/opencv4/

# install opencv3
RUN apt-get install -y wget
RUN cd /home/catkin_ws/src && wget https://github.com/opencv/opencv/archive/refs/tags/3.4.16.tar.gz
RUN cd /home/catkin_ws/src && tar -zxvf 3.4.16.tar.gz
RUN cd /home/catkin_ws/src/opencv-3.4.16 && mkdir build
RUN cd /home/catkin_ws/src/opencv-3.4.16/build && cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
rm ../../3.4.16.tar.gz && make -j9 && sudo make install

#install realsense
#RUN apt-get install -y software-properties-common
RUN mkdir -p /etc/apt/keyrings
RUN curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | sudo tee /etc/apt/keyrings/librealsense.pgp > /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | \
sudo tee /etc/apt/sources.list.d/librealsense.list
RUN apt update -y && apt-get install -y librealsense2-dkms librealsense2-utils
RUN apt-get install -y librealsense2-dev librealsense2-dbg
RUN apt-get install -y ros-noetic-ddynamic-reconfigure
RUN cd /home/catkin_ws/src && git clone https://github.com/IntelRealSense/realsense-ros.git
RUN cd /home/catkin_ws/src/realsense-ros/ && git checkout `git tag | sort -V | grep -P "^2.\d+\.\d+" | tail -1`

RUN cd /home/catkin_ws/src && git clone https://github.com/dairal/common-sensors

# build catkin_ws
RUN cd /home/catkin_ws && . /opt/ros/noetic/setup.sh && catkin_make
RUN source /home/catkin_ws/devel/setup.bash