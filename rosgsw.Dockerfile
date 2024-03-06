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

##################################################
# Production
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
