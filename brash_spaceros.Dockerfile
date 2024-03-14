################################################
# Build ros-base                               #
# (ROS2 image with default packages)           #
################################################
FROM osrf/space-ros AS spaceros_demos
ENV DEBIAN_FRONTEND=noninteractive


RUN sudo apt-get update \
  && sudo apt-get install -y python3-rosinstall-generator
# Needed for OpenGL fix for Rviz to display
# && apt-get install -y software-properties-common \
# && add-apt-repository -y ppa:kisak/kisak-mesa \ 
# && apt update \ 
# && apt -y upgrade 
  
# Switch to bash shell
SHELL ["/bin/bash", "-c"]

USER ${USERNAME}
WORKDIR ${HOME_DIR}

# Create a workspace for spaceros_robots
WORKDIR ${HOME_DIR}
RUN mkdir -p ${HOME_DIR}/extra_deps_ws
WORKDIR ${HOME_DIR}/extra_deps_ws
RUN mkdir src

# Generate repos file for moveit2 dependencies, excluding packages from Space ROS core.
COPY --chown=${USERNAME}:${USERNAME} ./config/spaceros/extra_pkgs.txt /tmp/
COPY --chown=${USERNAME}:${USERNAME} ./config/spaceros/excluded_pkgs.txt /tmp/
RUN rosinstall_generator \
  --rosdistro humble \
  --deps \
  --exclude $(cat /tmp/excluded_pkgs.txt) \
  -- $(cat /tmp/extra_pkgs.txt) \
  > /tmp/extra_generated_pkgs.repos

# Get the repositories required to simulate the robots, but not included in Space ROS
RUN vcs import src < /tmp/extra_generated_pkgs.repos

# Install system dependencies
RUN source ${HOME_DIR}/spaceros/install/setup.bash \
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROSDISTRO} -r -y --skip-keys "console_bridge generate_parameter_library fastcdr fastrtps rti-connext-dds-5.3.1 rmw_connextdds ros_testing rmw_connextdds rmw_fastrtps_cpp rmw_fastrtps_dynamic_cpp composition demo_nodes_py lifecycle rosidl_typesupport_fastrtps_cpp rosidl_typesupport_fastrtps_c ikos diagnostic_aggregator diagnostic_updater joy qt_gui rqt_gui rqt_gui_py"

# Build the dependencies workspace
RUN colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Build demos
RUN mkdir -p ${HOME_DIR}/spaceros_demos_ws
WORKDIR ${HOME_DIR}/spaceros_demos_ws
RUN mkdir src
COPY --chown=${USERNAME}:${USERNAME} ./config/spaceros/demo_manual_pkgs.repos demo_manual_pkgs.repos
RUN vcs import src < demo_manual_pkgs.repos

# Get dependencies
RUN source ${HOME_DIR}/extra_deps_ws/install/setup.bash &&  \
    rosdep install --from-paths src --ignore-src -r -y

# Build the demos workspace
RUN source ${HOME_DIR}/extra_deps_ws/install/setup.bash && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Workdir
WORKDIR ${HOME_DIR}/spaceros_demos_ws

