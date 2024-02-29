FROM osrf/ros:humble-desktop AS rover-rosgsw-dev
ENV DEBIAN_FRONTEND=noninteractive

# Set user
ARG USERNAME=brash_user
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
  sqlitebrowser

# Set user from root to non-root
USER $USERNAME

# Disable StrictHostKeyChecking
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"

# Build bthe brash workspace
RUN mkdir -p /home/$USERNAME/brash_ws
WORKDIR /home/$USERNAME/brash_ws

RUN git clone git@github.com:traclabs/brash.git 
RUN cd brash 
RUN mkdir src 
RUN    vcs import src < brash.repos 

# Build the brash workspace
WORKDIR /home/$USERNAME/brash_ws/brash
RUN source /opt/ros/humble/setup.bash &&  \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Download juicer
WORKDIR /home/$USERNAME/brash_ws
RUN  git clone https://github.com/WindhoverLabs/juicer.git --recursive && \
     cd juicer && \ 
     git checkout archive_unions && \
     make

# Set workspace
WORKDIR /home/$USERNAME/brash_ws/brash
