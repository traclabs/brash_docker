# Modified version from LuCCI project docker
# to work with Jammy and ROS2 Humble
FROM ubuntu:jammy AS jaxa-testing

RUN apt-get -y update
RUN apt-get install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Install ROS 2
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update
RUN apt-get install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y ros-humble-ros-base python3-argcomplete
RUN apt-get install -y ros-dev-tools

# Install dependencies of the ROS - cFS bridge
RUN apt-get install -y libwebsockets-dev protobuf-c-compiler libprotobuf-c-dev
RUN apt-get install -y pip
RUN pip install protobuf websockets

# Install other dev tools
RUN apt-get install -y git

# This is strictly not needed, but makes debugging and demonstration easier
RUN apt-get install -y screen vim gdb


# Fix temporal issue with protobuf incompatible versioning
# See my comment in the github issue: https://github.com/space-ros/space-ros/discussions/147#discussioncomment-10456694
RUN pip install protobuf==3.20.*

## Create ROS workspace
WORKDIR /root
RUN mkdir -p code 
WORKDIR /root/code
RUN mkdir -p rosws && mkdir cfs && mkdir racs2_bridge

SHELL ["/bin/bash", "-c"]

# Adjust screen to run bash as the default shell.
RUN echo "defshell -bash" > /root/.screenrc
