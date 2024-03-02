#!/bin/bash

ROOT_PATH=$PWD
CODE_DIR="code"
CFS_BRANCH="demo/husky_navigation"

# Download brash and juicer, used for rosgsw/rosfsw and cFS, used by fsw
download_code()
{
 pushd $ROOT_PATH
 mkdir $CODE_DIR
 cd $CODE_DIR

 # Download brash
 git clone git@github.com:traclabs/brash
 cd brash
 mkdir src
 vcs import src < brash.repos
 popd
 pushd $ROOT_PATH
 cd $CODE_DIR

 # Download juicer
 git clone git@github.com:WindhoverLabs/juicer.git --recursive 
 cd juicer 
 git checkout archive_unions
 popd
 pushd $ROOT_PATH
 cd $CODE_DIR

 # Download cFS
 git clone git@github.com:traclabs/cFS.git
 cd cFS
 git checkout $CFS_BRANCH
 git submodule init
 git submodule update
 popd
 pushd $ROOT_PATH
}


# ************************
# Download everything
download_code
