Edoras
=======


This docker setup has as a goal to test the JAXA bridge to have a
better idea of similar tools that are currently out there.

Build container
-----------------
   
1. Clone this repository:
   
   ```
   cd ~/
   git clone -b feature/jaxa_bridge git@github.com:traclabs/brash_docker
   ```
2. Build base image, then clone repos and build cfs & ros workspace:

   ```
   cd brash_docker
   ./scripts/build_images.sh
   ./scripts/clone_libraries.sh
   ./scripts/build_cfs.sh
   ./scripts/build_rosws.sh
   ```
   
Run JAXA example (Case 1)
--------------------------

These instructions are similar to these: https://github.com/jaxa/racs2_bridge/tree/main/Example/Case.1 (starting from "Start the bridge nodes", only that ran into the container:

1. First of all, start spinning the services so the docker container starts:

   ```
   # In brash_docker
   docker compose -f docker-compose-dev.yml up
   ```
2. In another terminal, open a terminal into the container and start the bridge node (ROS2):

   ```
   docker exec -it brash_docker-rosws-1 bash
   source install/setup.bash
   ros2 run bridge_py_s bridge_py_s_node  --ros-args --params-file ./src/bridge_py_s/config/params.yaml
   ```
3. Start the ROS2 nodes:

   ```
   docker exec -it brash_docker-rosws-1 bash
   source install/setup.bash
   ros2 run  subscriber_c2s  subscriber_c2s_node
   ```
4. Start the cFS applications:

   ```
   docker exec -it brash_docker-rosws-1 bash
   cd /root/cfs
   cd build/exe/cpu1
   ./core-cpu1
   ```

5. You should see a flow of information going from cFS to the ROS2 subscriber node.

   

