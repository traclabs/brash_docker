Instructions on how to run the brash docker can be found in our main documentation page: https://traclabs-brash.bitbucket.io/index.html , specifically:

**Instructions to build the brash docker images**

https://traclabs-brash.bitbucket.io/brash_docker_build.html

**Run the RoboSim demo using the docker images**

https://traclabs-brash.bitbucket.io/brash_docker_robo_sim.html


The rest of this README is mostly for internal development purposes. So, if you are a  new user, try the instructions in the traclabs-brash's links mentioned above.





**Table of Contents:**

1. [Building the Docker image](#setup)
   - [Common Setup](#common-setup)
   - [Build Production mode](#prod)
   - [Build Devel mode](#dev) 
3. [Running the Docker images](#running-the-docker-images)
   

# Docker Test Environment

This is a containerized environment to quickly get started with the brash system, in 'development' or 'production' configurations.  The containers have been tested with both Docker and Podman.

NOTE: Static IP addresses are required because cFE does not support DNS lookup and requires IP address to be pre-compiled in the SBN configuration table.  To use dynamic IPs, we would need to re-compile the cfe tables on each startup of the system.  

At present, all network configurations are split between 3 locations (plus compiled-in defaults)
- docker-compose.yml
- env.sh
- cFS/sample_defs/tables/*sbn_conf_tbl.c  # Docker configuration uses cpu2 setup

## ARM Based Machines (ie: Mac M*)

This applies to hosts such as Apple M* processors, Pis, etc.

An ARM-based image may be required for proper functionality (and improved performance). The official ROS Docker image does not include an ARM-based build.

Edit the ros-base-Dockerfile and change the image to `arm64v8/ros:galactic`


# Setup
Begin with the [**Common Setup**](#common-setup) subsection, then procede to either the [Dev](#dev) or [Prod](#prod) section.

1. **[Prod](#prod) setup** : This generates a fresh, static build of the complete system with minimal steps. This mode is suitable for continuous integration systems, demos, and end-user testing.

2. **[Dev](#dev) setup** : This configuration is optimized for developers frequently editing and rebuilding. This configuration uses a shared volume to access this folder and allows for quicker iterative builds.

## Common Setup

### Pre-requisites

- **docker-compose** must be available to build and run (you can install Docker Engine following [these instructions](https://docs.docker.com/engine/install/ubuntu/)).  This setup has been tested using docker, but should also work with **podman** with minimal effort.
- **git** and **vcstool** are required for source code checkout (`pip3 install vcstool`).
- All commands should be executed from this folder.
- Ensure network connectivity is available. If running behind a proxy, ensure that any related settings or certificates have been setup.  In some cases, this may require tweaking the Dockerfiles before
  building.  For example adding to *ros-base-Dockerfile* :

   ```
   # Corporate Firewall Certificate Configuraiton
   COPY my.cer /usr/local/share/ca-certificates/my.crt
   RUN update-ca-certificates
   ```

### Checkout

1. Recursively clone this repository:
   ```
   git clone --recursive git@github.com:traclabs/brash_docker
   ```
   If you've already cloned the repository without the recursive flag, you may run `git submodule update --init --recursive` to complete the base checkout.

2. ROS packages are currently configured using the `vcstool`.  This tool clones the required repositories (which will be downloaded to brash/src) using either https or ssh based Github links.

   ```
   pushd brash
   mkdir src
   vcs import src < https.repos     # User choice of https.repos or ssh.repos
   ```

## Prod

In your terminal:
```
# Go to your main repository folder, for instance
cd ${HOME}/brash_docker 

# Load ENV variables and aliases
source setup.sh

# Build the Docker containers (this can take several minutes)
docker-compose build

# Run
docker-compose up
```

See the [Running](#running-the-docker-images) section below for additional usage information.

## Dev
In your terminal:
```
# Go to your main repository folder, for instance
cd ${HOME}/brash_docker

# Run docker compose
source setup_dev.sh
docker-compose build

# Initial CFE Build
build_cfe prep SIMULATION=native
build_cfe install

# ROS Build
build_ros
```

For incremental builds, repeat the `build_cfe install` and/or `build_ros` steps as appropriate.  

For a clean cfe build, simply `rm -rf cFS/build` and repeat both build steps above.

For a clean ROS build, `rm -rf brash/build`


# Running the Docker images

Always run the setup script in every new terminal to configure docker-compose and aliases. Use the 'alias' command, or inspect the contents of these setup scripts for details on interacting with the running system:
```
 $ ./setup.sh  # or setup_dev.sh, if in devel mode 
```

Start the system with **docker-compose**.  See docker-compose documentation for usage details.
- `docker-compose up -d` to start the system
  - The '-d' flag causes docker to startup in the background as a daemon. Omit to keep it in the foreground
- `docker-compose down` to stop the system
- `docker-compose restart ${NAME}` to restart a single service. Defined services are fsw, rosgsw, and rosfsw.

CFE output is shown directly in the shell.  If you started docker-compose in daemon mode (or for a filtered log), simply run `docker-compose logs fsw`.

Log files for each ROS application are saved to brash/*.log. TIP: The tool "multitail" can be installed from most package managers to provide an easy method to tail multiple files at once, ie: `multitail brash/*.log`

To enable TLM output (TODO: Make this automatic):
- `ros_to_en`

A "noVNC" server is included in this docker-compose setup for easy execution of GUI applications.  Any GUI launched from the rosgsw or rosfsw machines will be accessible at http://localhost:8080/vnc.html   

An alias to launch the rqt tool on rosgsw is `rosgsw_rqt`.  

To open a shell for issuing multiple ROS service commands on the rosgsw instance:
- `docker-compose exec -it -w /shared/brash -it rosgsw bash`
- Example commands include the following (see main documentation for more)
  - `ros2 topic pub --once /groundsystem/to_lab_enable_output_cmd cfe_msgs/msg/TOLABEnableOutputCmdt '{"payload":{"dest_ip":"10.5.0.2"}}'`
  - `ros2 service call /cfdp/cmd/put cfdp_msgs/srv/CfdpXfrCmd '{src: "test1.txt", dst: "test2.txt", "dstid" :2}'`
  

For debugging, network activity can be monitored with tshark. The pcap file can be opened in a local Wireshark instance for easier viewing.
- `docker-compose exec -w /shared -it fsw tshark -w test.pcap -f udp`

# Troubleshooting

## cFS Mqueue errors

The provided cfs-Dockerfile has been configured to run as a non-root user in order to suppress internal checks that will otherwise prevent cfe from starting up with an errour concerning maximum number of message queues. In this configuration cfe will run, but may drop messages in some circumstances.

Another  approach is to alter `docker-compose-prod.yml` to add `privileged: true` to the `fsw` image definition.

This can also be resolved (for Linux systems) by directly increasing the limit with:

   `echo 128 | sudo tee /proc/sys/fs/mqueue/msg_max`
   
On Mac systems, the above command needs to be executed from within the VM hosting the daemon.  If using podman, this can be accessed with `podman machine ssh`.  If using [colima](https://github.com/abiosoft/colima) for Docker, connect with `colima ssh`. 
