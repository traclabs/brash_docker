
Build demo for rover
======================

1. Download the code:
   
   ```
   $ cd brash_docker/config/rover_demo
   $ ./setup.sh

2. Build the cFS dev image
   ```
   $ env UID=${UID}  docker compose -f rover_demo_compose_devel.yml build fsw
   ```

3. Build the ros-base image:

   ```
   $ cd brash_docker/config/rover_demo
   $ docker build -f brash_ros_base.Dockerfile . --build-arg="USER_UID=$UID" -t brash-ros-base --target brash-ros-base
   ```
   
4. Build the rosgsw and rosfsw images:
   ```
   $ env UID=${UID}  docker compose -f rover_demo_compose_devel.yml build rosgsw
   $ env UID=${UID}  docker compose -f rover_demo_compose_devel.yml build rosfsw
   ```

Run
====

1. Run the 3 dockers. These services just keep the containers running:

   ```
   $ docker compose -f rover_demo_compose_devel.yml up fsw
   $ docker compose -f rover_demo_compose_devel.yml up novnc   
   $ docker compose -f rover_demo_compose_devel.yml up rosgsw
   $ docker compose -f rover_demo_compose_devel.yml up rosfsw
   ```
  
   And you can open a terminal in the container:
   ```
   $ docker exec -it  rover_demo-fsw-1  bash
   $ docker exec -it  rover_demo-rosgsw-1  bash
   $ docker exec -it  rover_demo-rosfsw-1  bash
   ```

1. Build docker (Devel mode)
   --------------------------
      
```  
$ cd brash_docker
$ docker compose --project-directory . -f config/rover_demo/docker-compose-dev-rover.yml  build rosgsw
```

# Build brash-ros-base-rover

```
$ docker compose --project-directory . -f config/rover_demo/docker-compose-dev-rover.yml  run  -w /shared/brash rosgsw  colcon build --symlink-install
```
# Build brash

```
$ docker compose --project-directory . -f config/rover_demo/docker-compose-dev-rover.yml run -w /shared/brash rosfsw colcon build --symlink-install
```

#RUN!!!

# Start cfs

```
docker-compose -f docker-compose-dev.yml up fsw
```

# Start nvc
```
docker-compose -f docker-compose-dev.yml up novnc
```

# Start rosfsw
 
```
docker-compose --project-directory . -f config/rover_demo/docker-compose-dev-rover.yml up rosfsw
```

# In ROSFSW
 
```
$ docker exec -it  brash_docker-rosfsw-1  bash
$ source install/setup.bash
$ ros2 launch clearpath_gz simulation.launch.py setup_path:=/home/traclabs_user/rover_ws

$ # Remember to press PLAY!
```
 
# Send commands

```
$ docker exec -it  brash_docker-rosfsw-1  bash
$ source install/setup.bash

$ ros2 topic pub -r 10 /w200_0000/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.3, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}"
```




ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist "{linear: {x: -0.3, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}"
