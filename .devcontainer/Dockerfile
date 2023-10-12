FROM osrf/ros:humble-desktop-full

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash

# Add vscode user with same UID and GID as your host system
# (copied from https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch from root to user
USER $USERNAME

# Update all packages
RUN sudo apt update && sudo apt upgrade -y

# Source the ROS setup file
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /home/$USERNAME/ros/brash/install/local_setup.bash" >> ~/.bashrc

# # Switch to bash shell
SHELL ["/bin/bash", "-c"]

# get various packages
RUN sudo apt update -y
RUN export DEBIAN_FRONTEND=noninteractive
RUN sudo apt -y install git python3-pip python3-rosdep python3-wstool python3-colcon* nodejs git-man man openssh-client less curl
RUN sudo apt -y upgrade
RUN sudo pip3 install vcstool
RUN source /opt/ros/${ROS_DISTRO}/setup.bash
RUN rosdep update

# Copy the cloned repositories into container
RUN sudo rm -r /var/cache/* /var/lib/apt/lists/*
RUN mkdir -p /home/$USERNAME/ros/openmct-ros
RUN mkdir -p /home/$USERNAME/cFS
RUN mkdir -p /home/$USERNAME/ros/brash
COPY --chown=$USERNAME:$USERNAME ros/openmct-ros /home/$USERNAME/ros/openmct-ros/.
COPY --chown=$USERNAME:$USERNAME cFS /home/$USERNAME/cFS/.
COPY --chown=$USERNAME:$USERNAME ros/brash /home/$USERNAME/ros/brash/.

# install openmct plugin
WORKDIR /home/$USERNAME/ros/openmct-ros
RUN npm audit fix --force
# RUN npm install --verbose
# RUN npm run build:example

# Build cFS 
WORKDIR /home/$USERNAME/cFS
RUN make SIMULATION=native prep
RUN make
RUN make install

# Build ROS workspace
WORKDIR /home/$USERNAME/ros/brash
RUN sudo apt update
RUN sudo apt install -y ros-dev-tools ros-humble-joint-state-publisher-gui
RUN sudo rosdep install -i --from-path src --rosdistro ${ROS_DISTRO} -y
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
    && colcon build --symlink-install

