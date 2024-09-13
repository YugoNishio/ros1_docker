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

# pip & YOLO install
RUN apt-get install -y python3-pip
RUN pip install ultralytics

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
# install eog
RUN apt-get install -y eog

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
RUN cd /home/catkin_ws/src && git clone -b noetic-devel https://github.com/ros-industrial/universal_robot.git
RUN rosdep update
RUN cd /home/catkin_ws/
RUN rosdep install -y --rosdistro noetic --ignore-src --from-paths /home/catkin_ws/src

# change build command
#RUN apt-get update && apt-get install -y python3-catkin-tools
#RUN cd /home/catkin_ws && rm -rf build/ devel/
#RUN cd /home/catkin_ws && catkin init

# remove opencv4
RUN rm -r /usr/lib/x86_64-linux-gnu/cmake/opencv4/

# install opencv3
RUN apt-get install -y wget
RUN cd /home/catkin_ws/src && wget https://github.com/opencv/opencv/archive/refs/tags/3.4.16.tar.gz
RUN cd /home/catkin_ws/src && tar -zxvf 3.4.16.tar.gz
RUN cd /home/catkin_ws/src/opencv-3.4.16 && mkdir build
RUN cd /home/catkin_ws/src/opencv-3.4.16/build && cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
rm ../../3.4.16.tar.gz && make -j9 && sudo make install

RUN echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc && source ~/.bashrc

# install ur5 package
RUN cd /home/catkin_ws/src && git clone https://github.com/dairal/ur5-joint-position-control.git
#RUN cd /home/catkin_ws/src && git clone https://github.com/dairal/ur5-tcp-position-control.git
RUN cd /home/catkin_ws/src && git clone https://github.com/filesmuggler/robotiq.git
RUN cd /home/catkin_ws/src && git clone https://github.com/dairal/common-sensors
RUN cd /home/catkin_ws/src && git clone https://github.com/dairal/opencv_services.git
RUN cd /home/catkin_ws/src && git clone https://github.com/dairal/ur5_pick_and_place_opencv.git

# build catkin_ws
RUN cd /home/catkin_ws && . /opt/ros/noetic/setup.sh && catkin_make
#RUN cd /home/catkin_ws && . /opt/ros/noetic/setup.sh && catkin build
RUN source /home/catkin_ws/devel/setup.bash