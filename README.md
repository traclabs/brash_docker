# Docker Test Environment

NOTE: Static IP addresses are required because cFE does not support DNS lookup and requires IP address to be pre-compiled in the SBN configuration table.  To use dynamic IPs, we would need to re-compile the cfe tables on each startup of the system.  

At present, all network configurations are split between 3 locations (plus compiled-in defaults)
- docker-compose.yml
- env.sh
- cFS/sample_defs/tables/*sbn_conf_tbl.c  # Docker configuration uses cpu2 setup

## ARM Based Machines

This applies to hosts such as Apple M* processors, Pis, etc.

An ARM-based image may be required for proper functionality (and improved performance). The official ROS Docker image does not include an ARM-based build.

Edit the ros-base-Docerfile and change the image to `arm64v8/ros:galactic`

# Setup
These instruction are for a dev environment where source files are mounted to allow for easy incremental builds.

## Pre-requisites
- All commands should be executed from this folder
- Ensure network connectivity is available. If running in a VPN, ensure that any related settings or certificates have been setup.
- Edit brash/checkout_and_install.sh to use ssh.repo if desired (ssh-keys required) in place of the default https.repos.

## Initial Setup
- Install docker (or podman and alias)
- Download and build base Docker images
  - `docker-compose build`
- Checkout ROS System (note: a single build is used for both fsw and gsw instances)
  - SSH
    - Place an SSH Private Key authenticated to your bitbucket account in this folder
    - `docker run --rm -it -v ${PWD}:/shared -w /shared/brash brash-ros bash`
    - `mkdir ~/.ssh && cp id_rsa ~/.ssh/`
        - Alternatively, run "ssh-keygen" and cat your public key to add to your bitbucket account
    - To save your SSH key for future operations run: `docker ps` to identify the name of the running Docker instance, then commit your new key with `docker commit $name brash-ros:latest`
    - ./checkout_and_install.sh
  - HTTPS
    - VCStool does not behave correctly with password prompts, so extra setup is required
    - Edit brash/checkout_and_install.sh to use https.repos instead of ssh.repos (or run commands manually when indicated below)
    - `docker run --rm -it -v ${PWD}:/shared -w /shared/brash brash-ros bash`
    - `git config --global credential.helper cache --timeout=86400`    # Set git to cache passwords in memory
    - `git config --global safe.directory "*"`
    - Clone a repository (such a this one) temporarily to cache your credentials, then delete it. (WORKAROUND for vcstool bug)
    - ./checkout_and_install.sh
- Build cfe
  - `docker run --rm -it -v ${PWD}:/shared -w /shared/cFS cfs-base make prep SIMULATION=native`
  - `docker run --rm -it -v ${PWD}:/shared -w /shared/cFS cfs-base make install`

## Incremental Builds
NOTE: Linux users may be able to build natively, however for consistency it is recommended to always build within the Docker environment.

CFE:
- `docker run --rm -it -v ${PWD}:/shared -w /shared/cFS cfs-base make install`
  
ROS:
- `docker run --rm -it -v ${PWD}:/shared -w /shared/brash brash-ros colcon build`
    
# Running

Start the system with docker-compose.  See docker-compose documentation for usage details.
- `docker-compose up -d` to start the system
  - The '-d' flag causes docker to startup in the background as a daemon. Omit to keep it in the foreground
- `docker-compose down` to stop the system
- `docker-compose restart ${NAME}` to restart a single service. Defined services are fsw, rosgsw, and rosfsw.

Log files for each ROS application are saved to brash/*.log. TIP: The tool "multitail" can be installed from most package managers to provide an easy method to tail multiple files at once, ie: `multitail brash/*.log`

To enable TLM output (TODO: Make this automatic):
- `docker exec -w /shared/brash -it brash-rosgsw-1 ./exec_rosgsw_toen.sh`

To open a shell for issuing multiple ROS service commands on the rosgsw instance:
- `docker exec -it -w /shared/brash -it brash-rosgsw-1 bash`
- `source /opt/ros/humble/setup.sh && source install/local_setup.sh`
- Example commands include the following (see main documentation for more)
  - `ros2 topic pub --once /groundsystem/to_lab_enable_output_cmd cfe_msgs/msg/TOLABEnableOutputCmdt '{"payload":{"dest_ip":"10.5.0.2"}}'`
  - `ros2 service call /cfdp/cmd/put cfdp_msgs/srv/CfdpXfrCmd '{src: "test1.txt", dst: "test2.txt", "dstid" :2}'`
  

For debugging, network activity can be monitored with tshark. The pcap file can be opened in a local Wireshark instance for easier viewing.
- `docker exec -w /shared -it brash-fsw-1 tshark -w test.pcap -f udp`
