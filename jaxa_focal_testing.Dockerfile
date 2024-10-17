# Created by:
# Software Team
# Lunar Command and Control Interoperability (LuCCI) Project
# National Aeronautics and Space Administration
# Software Team POC: ivan.perezdominguez@nasa.gov
# Authorized for public release (April 2, 2024 3:46 PM Pacific)
FROM ubuntu:focal AS jaxa-testing

RUN apt-get -y update
RUN apt-get install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# Install ROS 2
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update
RUN apt-get install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y ros-foxy-ros-base python3-argcomplete
RUN apt-get install -y ros-dev-tools

# Install dependencies of the ROS - cFS bridge
RUN apt-get install -y libwebsockets-dev protobuf-c-compiler libprotobuf-c-dev
RUN apt-get install -y pip
RUN pip install protobuf websockets

# Install other dev tools
RUN apt-get install -y git

# This is strictly not needed, but makes debugging and demonstration easier
RUN apt-get install -y screen vim gdb

# Clone bridge first. The bridge has both cFS and ROS content we need before we
# compile either.
WORKDIR /root
RUN git clone https://github.com/jaxa/racs2_bridge

# Prepare cFS

## Clone cFS
WORKDIR /root
RUN git clone --recursive -b v6.7.0a https://github.com/nasa/cFS/ cfs
WORKDIR /root/cfs
RUN git submodule init
RUN git submodule update

## Customize cFS to run the bridge
RUN cp cfe/cmake/Makefile.sample Makefile
RUN cp -r cfe/cmake/sample_defs sample_defs
RUN cp -pr /root/racs2_bridge/cFS/Bridge/Client_C/apps/racs2_bridge_client /root/cfs/apps/
# The following are the sample_defs needed if we only want the bridge and not the sample app.
# RUN cp -p /root/racs2_bridge/cFS/Bridge/Client_C/sample_defs/* /root/cfs/sample_defs/

## Deploy the sample talker application and adjust the startup scripts.
RUN cp -pr /root/racs2_bridge/Example/Case.1/cFS/sample_defs/* /root/cfs/sample_defs/
RUN cp -pr /root/racs2_bridge/Example/Case.1/cFS/apps/sample_talker /root/cfs/apps/

## This is necessary to run cFS inside docker, apparently.
RUN sed -i -e 's/^#undef OSAL_DEBUG_PERMISSIVE_MODE/#define OSAL_DEBUG_PERMISSIVE_MODE 1/g' sample_defs/default_osconfig.h
RUN sed -i -e 's/^#undef OSAL_DEBUG_DISABLE_TASK_PRIORITIES/#define OSAL_DEBUG_DISABLE_TASK_PRIORITIES 1/g' sample_defs/default_osconfig.h

## This is only needed because docker by default starts in IPv4. This setting
## is specific to the JAXA bridge.
RUN sed -i -e 's/^wss_uri=.*/wss_uri=127.0.0.1/g' sample_defs/racs2_bridge_config.txt

## Compile cFS
RUN make SIMULATION=native prep
RUN make
RUN make install

# Prepare ROS packages

## Create ROS workspace
WORKDIR /root
RUN mkdir -p ros2-project/src

## Copy packages (bridge and demo listener).
RUN cp -pr /root/racs2_bridge/ROS2/Bridge/Server_Python/bridge_py_s /root/ros2-project/src/
RUN cp -pr /root/racs2_bridge/Example/Case.1/ROS2/* /root/ros2-project/src/

## Compile and install ROS 2 packages
WORKDIR /root/ros2-project
SHELL ["/bin/bash", "-c"]
RUN source /opt/ros/foxy/setup.bash && colcon build --symlink-install

## This is only needed because docker by default starts in IPv4. This setting
## is specific to the JAXA bridge.
RUN sed -i -e 's/wss_uri:.*/wss_uri: "127.0.0.1"/g' ./src/bridge_py_s/config/params.yaml

# Adjust screen to run bash as the default shell.
RUN echo "defshell -bash" > /root/.screenrc
