#!/bin/sh

# install vim
sudo apt-get update -qq
sudo apt-get install -y tzdata
sudo apt-get update && sudo apt-get install -y vim git lsb-release sudo gnupg tmux curl

# install terminator
sudo apt-get install -y terminator

# pip & YOLO install
sudo apt-get install -y python3-pip
pip install ultralytics

sudo apt-get install -y ros-noetic-rqt-* 
sudo apt-get install -y python3-catkin-tools
sudo apt-get install -y ros-noetic-ros-control ros-noetic-ros-controllers
sudo apt-get install -y ros-noetic-rviz
sudo apt-get install -y ros-noetic-rviz-visual-tools
sudo apt-get install -y ros-noetic-moveit-visual-tools
sudo apt-get install -y ros-noetic-moveit ros-noetic-moveit-planners-ompl
sudo apt-get install -y ros-noetic-control*
sudo apt-get install -y ros-noetic-rosbridge-suite
sudo apt-get install -y ros-noetic-openni-launch
sudo apt-get install -y libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install -y ros-noetic-laser-filters
sudo apt-get install -y ros-noetic-pcl-ros
# install smach
sudo apt-get install -y ros-noetic-smach-ros ros-noetic-smach-viewer
# install eog
sudo apt-get install -y eog

# set catkin workspace
COPY config/git_clone.sh /home/ubuntu/git_clone.sh
echo "source /opt/ros/noetic/setup.sh" >> .bashrc
mkdir -p catkin_ws/src
cd catkin_ws/src && . /opt/ros/noetic/setup.sh && catkin_init_workspace
cd && cd catkin_ws && . /opt/ros/noetic/setup.sh && catkin_make
echo "source ./catkin_ws/devel/setup.bash" >> .bashrc

COPY config/.bashrc /home/ubuntu/.bashrc
COPY config/.vimrc /home/ubuntu/.vimrc

# clean workspace
rm -rf git_clone.sh

# install universal_robot package
cd /home/ubuntu/catkin_ws/src && git clone -b noetic-devel https://github.com/ros-industrial/universal_robot.git
rosdep update
cd /home/ubuntu/catkin_ws/
rosdep install -y --rosdistro noetic --ignore-src --from-paths /home/catkin_ws/src

# change build command
#sudo apt-get update && apt-get install -y python3-catkin-tools
#RUN cd /home/catkin_ws && rm -rf build/ devel/
#RUN cd /home/catkin_ws && catkin init

# remove opencv4
rm -rf /usr/lib/x86_64-linux-gnu/cmake/opencv4/

# install opencv3
sudo apt-get install -y wget
cd /home/ubuntu/catkin_ws/src && wget https://github.com/opencv/opencv/archive/refs/tags/3.4.16.tar.gz
cd /home/ubuntu/catkin_ws/src && tar -zxvf 3.4.16.tar.gz
cd /home/ubuntu/catkin_ws/src/opencv-3.4.16 && mkdir build
cd /home/ubuntu/catkin_ws/src/opencv-3.4.16/build && cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
rm ../../3.4.16.tar.gz && make -j9 && sudo make install

echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc && source ~/.bashrc

# install ur5 package
cd /home/ubuntu/catkin_ws/src && git clone https://github.com/dairal/ur5-joint-position-control.git
#RUN cd /home/ubuntu/catkin_ws/src && git clone https://github.com/dairal/ur5-tcp-position-control.git
cd /home/ubuntu/catkin_ws/src && git clone https://github.com/filesmuggler/robotiq.git
cd /home/ubuntu/catkin_ws/src && git clone https://github.com/dairal/common-sensors
cd /home/ubuntu/catkin_ws/src && git clone https://github.com/dairal/opencv_services.git
cd /home/ubuntucatkin_ws/src && git clone https://github.com/dairal/ur5_pick_and_place_opencv.git

# build catkin_ws
cd /home/ubuntu/catkin_ws && . /opt/ros/noetic/setup.sh && catkin_make
#RUN cd /home/ubuntu/catkin_ws && . /opt/ros/noetic/setup.sh && catkin build
source /home/ubuntu/catkin_ws/devel/setup.bash
