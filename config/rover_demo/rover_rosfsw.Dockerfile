FROM osrf/ros:humble-desktop AS rover-rosfsw-dev
ENV DEBIAN_FRONTEND=noninteractive

# Set user
ARG USERNAME=traclabs_user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Set bash shell
SHELL ["/bin/bash", "-c"]

RUN apt-get update \
# Needed for OpenGL fix for Rviz to display
 && apt-get install -y software-properties-common \
 && add-apt-repository -y ppa:kisak/kisak-mesa \ 
 && apt update \ 
 && apt -y upgrade 

RUN apt-get install -y \
  libnlopt-dev \
  libnlopt-cxx-dev \
  ros-humble-xacro \
  ros-humble-joint-state-publisher \
  ros-humble-srdfdom \
  ros-humble-controller-interface \
  ros-humble-realtime-tools \
  ros-humble-control-toolbox \
  ros-humble-joint-state-publisher-gui \
  ros-humble-geometric-shapes \
  ros-humble-controller-manager \
  ros-humble-joint-trajectory-controller \
  ros-humble-rqt* \
  libdwarf-dev \
  libelf-dev \
  libsqlite3-dev \
  sqlitebrowser  \
  
  ignition-fortress \
  ros-humble-ros-gz-sim \
  ros-humble-ros-gz-bridge \
  ros-humble-robot-localization \
  ros-humble-interactive-marker-twist-server \
  ros-humble-twist-mux \
  ros-humble-joy-linux \
  ros-humble-imu-tools \
  ros-humble-ign-ros2-control \
  ros-humble-joint-state-broadcaster \
  ros-humble-diff-drive-controller 
   

# Set user from root to non-root
USER $USERNAME

# Disable StrictHostKeyChecking
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"

# Build a rover_ws into container
RUN mkdir -p /home/$USERNAME/rover_ws
WORKDIR /home/$USERNAME/rover_ws

COPY --chown=${USERNAME}:${USERNAME} ./rover.repos rover.repos
COPY --chown=${USERNAME}:${USERNAME} ./robot.yaml robot.yaml
RUN mkdir src && vcs import src < rover.repos 

# Build the demo
RUN source /opt/ros/humble/setup.bash &&  colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release


# Copy the workspace into container
RUN mkdir -p /home/$USERNAME/test_ws
WORKDIR /home/$USERNAME/test_ws

# Install dependencies
#RUN rosdep update && \
#    rosdep install --from-paths src --ignore-src --default-yes -r || true && \
#    sudo rm -rf /var/lib/apt/lists/*

   
#RUN touch /home/$USERNAME/dexter_entrypoint.sh && \
#    chmod +x /home/$USERNAME/dexter_entrypoint.sh && \   
#    echo -e '#!/bin/bash \n echo "Sourcing dexter_ws. Ready to use"  \nsource "/home/vscode/dexter_ws/install/setup.bash"\nexec "$@"' > /home/$USERNAME/dexter_entrypoint.sh

#ENTRYPOINT ["/home/vscode/dexter_entrypoint.sh"]

WORKDIR /home/$USERNAME/test_ws
