FROM osrf/ros:humble-desktop AS brash-ros-base-rover

# For usage on ARM-based systems (including Macbook M*) switch to the base image below
#FROM arm64v8/ros:humble AS brash-ros-base

ARG DEBIAN_FRONTEND=noninteractive   # Prevent prompts during apt installs

# Set git credential helper to aide checkout (only prompt user once during installation if not using ssh keys)
RUN git config --global credential.helper 'cache --timeout=3600'


# Setup args
# Rover directory relative to top-docker folder
ARG ROVER_CONFIG_DIR=config/rover_demo

# Setup a non-root user with enough privileges
ARG USERNAME=brash_user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Note: libdwarf, libelf, libsqlite are dependencies of Juicer, usage of which is optional in a configured system.
RUN apt update \ 
    && apt install -y \ 
    python3-pip \ 
    ros-humble-rqt* \
    ros-humble-joint-state-publisher-gui \
    libdwarf-dev \
    libelf-dev \
    libsqlite3-dev \  
    ignition-fortress \
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
    && rm -rf /var/lib/apt/lists/*

# Set user from root to non-root
USER $USERNAME

# Switch to bash shell
SHELL ["/bin/bash", "-c"]

# Install cfdp    
RUN pip3 install cfdp

# Install the rover repositories
WORKDIR /home/$USERNAME
RUN mkdir -p rover_ws/src

# Clone the rover repos
WORKDIR /home/$USERNAME/rover_ws
COPY --chown=$USERNAME:$USERNAME ${ROVER_CONFIG_DIR}/rover.repos ./ 
COPY --chown=$USERNAME:$USERNAME ${ROVER_CONFIG_DIR}/robot.yaml ./ 
RUN vcs import  src < rover.repos

# Build the rover repos
RUN source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install
    
# Source the rover repos and brash workspace in every terminal
RUN echo "source /home/${USERNAME}/rover_ws/install/local_setup.bash" >> ~/.bashrc && \
    echo 'source /shared/brash/install/local_setup.bash' >> ~/.bashrc

# TODO: Build juicer
# cd /shared/juicer; make


