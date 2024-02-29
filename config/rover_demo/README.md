
Running demo for rover
======================

1. Build the rover-rosfsw image:

   ```
   $ cd brash_docker/config/rover_demo
   $ docker build -f rover_rosfsw.Dockerfile . -t rover-rosfsw --target rover-rosfsw-dev
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




ros2 topic pub -r 10 /w200_0000/cmd_vel geometry_msgs/msg/Twist "{linear: {x: -0.3, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}"
