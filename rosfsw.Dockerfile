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
  ros-humble-diff-drive-controller 

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
# Production
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
