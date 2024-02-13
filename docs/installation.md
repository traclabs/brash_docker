Installation
=============

**WARNING** : These are preliminary instructions to build Docker images
using Github actions. They could also be used by users who have their
github repositories set to use SSH in their machines.
At this stage, they are just for testing so do NOT use. Refer to the main 
README instead.

1. Download this repository:
   ```
   $ git clone git@github.com:traclabs/brash_docker.git brash_docker
   ```
2. Make sure the gitmodules are set up to use SSH instead of HTTP
   ```
   $ cd brash_docker
   $ perl -i -p -e 's|https://(.*?)/|git@\1:|g' .gitmodules
   ```
3. Init and update the submodules (brash, cFS and juicer):
   ```
   $ git submodule init
   $ git submodule update
   ```
4. **Brash workspace setup** : Pull repositories:
   ```
   $ cd brash
   $ mkdir src
   $ vcs import src < ssh.repos
   $ source /opt/ros/galactic/setup.bash
   $ colcon build --symlink-install
   $ ./colcon_test.sh
   
5. **cFS setup** : Pull repositories:
   ```
   $ cd ../cFS
   $ git submodule init
   $ git submodule update
   $ cp cfe/cmake/Makefile.sample Makefile
   $ cp -r cfe/cmake/sample_defs sample_defs
   $ make SIMULATION=native prep
   $ make
   $ make install
