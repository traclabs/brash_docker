cd brash
vcs import  src < ../config/rover_demo/rover.repos

cd brash_docker
docker-compose -f docker-compose-dev-rover.yml build

# Build cfs-base image

$ build_cfe prep SIMULATION=native
$ build_cfe install

# Build ros

docker-compose -f docker-compose-dev-rover.yml run  -w /shared/brash rosgsw colcon build --symlink-install



#RUN!!!

#Start cfs
 docker-compose -f docker-compose-dev.yml up fsw


#Start nvc
docker-compose -f docker-compose-dev.yml up novnc

# Start rosfsw
 docker-compose -f docker-compose-dev-rover.yml up rosfsw


# In ROSFSW
 docker exec -it  brash_docker-rosfsw-1  bash
 source install/setup.bash
 ros2 launch clearpath_gz simulation.launch.py setup_path:=/shared/brash

  Press PLAY!

# Send commands
 docker exec -it  brash_docker-rosfsw-1  bash
 source install/setup.bash



ros2 topic pub -r 10 /w200_0000/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.3, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}"

ros2 topic pub -r 10 /w200_0000/cmd_vel geometry_msgs/msg/Twist "{linear: {x: -0.3, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}"
