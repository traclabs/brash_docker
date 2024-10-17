#!/bin/bash


# Clone racs2_bridge **********************************************
git clone https://github.com/jaxa/racs2_bridge

# Clone cFS **********************************************
git clone --recursive -b v6.7.0a https://github.com/nasa/cFS/ cfs

# Update submodules
pushd cfs
git submodule init
git submodule update

## Customize cFS to run the bridge
cp cfe/cmake/Makefile.sample Makefile
cp -r cfe/cmake/sample_defs sample_defs
cp -pr ../racs2_bridge/cFS/Bridge/Client_C/apps/racs2_bridge_client apps/
# The following are the sample_defs needed if we only want the bridge and not the sample app.
# RUN cp -p ../racs2_bridge/cFS/Bridge/Client_C/sample_defs/* sample_defs/

## Deploy the sample talker application and adjust the startup scripts.
cp -pr ../racs2_bridge/Example/Case.1/cFS/sample_defs/* sample_defs/
cp -pr ../racs2_bridge/Example/Case.1/cFS/apps/sample_talker apps/

## This is necessary to run cFS inside docker, apparently.
sed -i -e 's/^#undef OSAL_DEBUG_PERMISSIVE_MODE/#define OSAL_DEBUG_PERMISSIVE_MODE 1/g' sample_defs/default_osconfig.h
sed -i -e 's/^#undef OSAL_DEBUG_DISABLE_TASK_PRIORITIES/#define OSAL_DEBUG_DISABLE_TASK_PRIORITIES 1/g' sample_defs/default_osconfig.h

## This is only needed because docker by default starts in IPv4. This setting
## is specific to the JAXA bridge.
sed -i -e 's/^wss_uri=.*/wss_uri=127.0.0.1/g' sample_defs/racs2_bridge_config.txt

popd

# In rosws folder *****************************************

## Copy packages (bridge and demo listener).
cp -pr racs2_bridge/ROS2/Bridge/Server_Python/bridge_py_s rosws/src/
cp -pr racs2_bridge/Example/Case.1/ROS2/* rosws/src/

## This is only needed because docker by default starts in IPv4. This setting
## is specific to the JAXA bridge.
sed -i -e 's/wss_uri:.*/wss_uri: "127.0.0.1"/g' rosws/src/bridge_py_s/config/params.yaml

