FROM osrf/ros:humble-desktop AS ros-base
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
# Needed for OpenGL fix for Rviz to display
 && apt-get install -y software-properties-common \
 && add-apt-repository -y ppa:kisak/kisak-mesa \ 
 && apt update \ 
 && apt -y upgrade 

RUN apt-get install -y \
  python3-pip \ 
  libnlopt-dev \
  libnlopt-cxx-dev \
  ros-humble-xacro \
  ros-humble-joint-state-publisher \
  ros-humble-srdfdom \
  ros-humble-rqt*

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

