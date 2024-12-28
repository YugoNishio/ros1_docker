FROM osrf/ros:humble-desktop-full

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

# colconのインストール
RUN apt-get install -y python3-colcon-common-extensions
RUN apt-get install -y python3-colcon-mixin \
&& colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml \
&& colcon mixin update default

RUN apt-get install -y python3-vcstool
RUN apt-get install -y gazebo ros-humble-gazebo-*
RUN apt-get install -y ros-humble-rqt-*
RUN apt-get install -y ros-humble-ros-testing
RUN apt-get install -y ros-humble-py-binding-tools
RUN apt-get install -y ros-humble-moveit-visual-tools
RUN apt-get install -y ros-humble-moveit ros-humble-moveit-planners-ompl

# ワークスペースの作成
RUN mkdir -p ~/ros2_ws/src
WORKDIR /home/ros2_ws/
RUN /bin/bash -c '. /opt/ros/humble/setup.bash; colcon build'

# install universal_robot package
RUN cd /home/ros2_ws/src && git clone -b humble https://github.com/UniversalRobots/Universal_Robots_ROS2_Driver.git
RUN rosdep update
RUN cd /home/ros2_ws/
RUN rosdep install -y --rosdistro humble --ignore-src --from-paths /home/ros2_ws/src

RUN cd /home/ros2_ws/src && git clone -b humble https://github.com/UniversalRobots/Universal_Robots_ROS2_Description.git

RUN cd /home/ros2_ws && source /opt/ros/humble/setup.bash && MAKEFLAGS="-j12 -l10" colcon build --executor sequential
RUN source /home/ros2_ws/install/setup.bash
RUN echo "source /home/ros2_ws/install/setup.bash" >> ~/.bashrc

COPY config/.bashrc /home/.bashrc
COPY config/.vimrc /home/.vimrc

# clean workspace
RUN rm -rf git_clone.sh