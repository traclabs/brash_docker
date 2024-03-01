FROM brash-ros-base AS brash-rosgsw
ENV DEBIAN_FRONTEND=noninteractive

ARG CODE_LOCAL=code

RUN sudo apt-get install -y \
  libnlopt-dev \
  libnlopt-cxx-dev \
  ros-humble-xacro \
  ros-humble-joint-state-publisher \
  ros-humble-srdfdom \
  ros-humble-joint-state-publisher-gui \
  ros-humble-geometric-shapes \
  ros-humble-rqt* \
  libdwarf-dev \
  libelf-dev \
  libsqlite3-dev \
  sqlitebrowser

WORKDIR ${CODE_DIR}

# Copy brash/juicer
COPY --chown=${USERNAME}:${USERNAME} ${CODE_LOCAL} ${CODE_DIR}

# Build the brash workspace
WORKDIR ${CODE_DIR}/brash
RUN source /opt/ros/humble/setup.bash &&  \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Build juicer
WORKDIR ${CODE_DIR}/juicer
RUN  make

# Set workspace
WORKDIR ${CODE_DIR}/brash
