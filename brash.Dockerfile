################################################
# Build ros-base                               #
# (ROS2 image with default packages)           #
################################################
FROM osrf/ros:humble-desktop AS ros-base
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
# Needed for OpenGL fix for Rviz to display
 && apt-get install -y software-properties-common \
 && add-apt-repository -y ppa:kisak/kisak-mesa \ 
 && apt update \ 
 && apt -y upgrade 

# Note: ros-humble-desktop is needed for ARM base image, but is already available for nominal -desktop image
RUN apt-get install -y \
  python3-pip \ 
  libnlopt-dev \
  libnlopt-cxx-dev \
  ros-humble-desktop \
  ros-humble-xacro \
  ros-humble-joint-state-publisher \
  ros-humble-srdfdom \
  ros-humble-rqt* \
  ros-humble-ament-cmake-test 

RUN pip3 install cfdp

# Switch to bash shell
SHELL ["/bin/bash", "-c"]

# Create a brash user
ENV USERNAME=brash_user
ENV HOME_DIR=/home/${USERNAME}
ENV CODE_DIR=/code

# Dev container arguments
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Create new user and home directory
RUN groupadd --gid ${USER_GID} ${USERNAME} \
&& useradd --uid ${USER_UID} --gid ${USER_GID} --create-home ${USERNAME} \
&& echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
&& chmod 0440 /etc/sudoers.d/${USERNAME} \
&& mkdir -p ${CODE_DIR} \
&& chown -R ${USER_UID}:${USER_GID} ${CODE_DIR}

USER ${USERNAME}
WORKDIR ${CODE_DIR}

################################################
# Build rosgsw-dev                             #
################################################

FROM ros-base AS rosgsw-dev
ENV DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get install -y \
  libnlopt-dev \
  libnlopt-cxx-dev \
  ros-humble-xacro \
  ros-humble-joint-state-publisher \
  ros-humble-srdfdom \
  ros-humble-joint-state-publisher-gui \
  ros-humble-geometric-shapes \
  ros-humble-rqt-robot-steering \
  ros-humble-rqt* \
  libdwarf-dev \
  libelf-dev \
  libsqlite3-dev \
  sqlitebrowser

# Set up sourcing
COPY --chown=${USERNAME}:${USERNAME} config/rosgsw_entrypoint.sh ${CODE_DIR}/entrypoint.sh
RUN echo 'source ${CODE_DIR}/entrypoint.sh' >> ~/.bashrc

# Get ready with brash workspace
RUN mkdir -p ${CODE_DIR}/brash
WORKDIR ${CODE_DIR}/brash

################################################
# Build rosfsw-dev                             #
################################################

FROM rosgsw-dev AS rosfsw-dev
ENV DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get install -y \
  ros-humble-controller-interface \
  ros-humble-realtime-tools \
  ros-humble-control-toolbox \
  ros-humble-geometric-shapes \
  ros-humble-controller-manager \
  ros-humble-joint-trajectory-controller \
  ros-humble-rqt* \
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
  ros-humble-diff-drive-controller \
  ros-humble-clearpath-gz

# Build a rover_ws into container
WORKDIR ${CODE_DIR}
RUN mkdir -p ${CODE_DIR}/rover_ws
WORKDIR ${CODE_DIR}/rover_ws

# Copy rover repos and robot config file required
COPY --chown=${USERNAME}:${USERNAME} ./config/rover.repos rover.repos
COPY --chown=${USERNAME}:${USERNAME} ./config/robot.yaml robot.yaml
RUN mkdir src && vcs import src < rover.repos 

# Build the rover workspace
RUN source /opt/ros/humble/setup.bash &&  \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Set up sourcing
COPY --chown=${USERNAME}:${USERNAME} ./config/rosfsw_entrypoint.sh ${CODE_DIR}/entrypoint.sh
RUN echo 'source ${CODE_DIR}/entrypoint.sh' >> ~/.bashrc


# Source from rover_ws
WORKDIR ${CODE_DIR}/brash



##################################################
# Build rosgsw (Production)
##################################################
FROM rosgsw-dev AS rosgsw

# Copy brash=
COPY --chown=${USERNAME}:${USERNAME} brash ${CODE_DIR}/brash

# Build the brash workspace
WORKDIR ${CODE_DIR}/brash
RUN source /opt/ros/humble/setup.bash &&  \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Build juicer
#COPY --chown=${USERNAME}:${USERNAME} juicer ${CODE_DIR}/juicer
#WORKDIR ${CODE_DIR}/juicer
#RUN  make

# Set workspace
WORKDIR ${CODE_DIR}/brash



##################################################
# Build rosfsw (Production)
##################################################
FROM rosfsw-dev AS rosfsw

# Copy brash
COPY --chown=${USERNAME}:${USERNAME} brash ${CODE_DIR}/brash

# Build the brash workspace
WORKDIR ${CODE_DIR}/brash
RUN source ${CODE_DIR}/rover_ws/install/setup.bash && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Build juicer
#COPY --chown=${USERNAME}:${USERNAME} juicer ${CODE_DIR}/juicer
#WORKDIR ${CODE_DIR}/juicer
#RUN  make

# Set workspace
WORKDIR ${CODE_DIR}/brash

