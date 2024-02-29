#!/bin/bash

ROOT_PATH=$PWD
BRASH_WS="brash_ws"

download_brash_ws()
{
 pushd $ROOT_PATH
 mkdir $BRASH_WS
 cd $BRASH_WS

 # Download brash
 git clone https://github.com/traclabs/brash
 cd brash
 mkdir src
 vcs import src < brash.repos
 popd
 pushd $ROOT_PATH
 cd $BRASH_WS

 # Download juicer
 git clone https://github.com/WindhoverLabs/juicer.git --recursive 
 cd juicer 
 git checkout archive_unions

}


# ************************
# Download everything
download_brash_ws
