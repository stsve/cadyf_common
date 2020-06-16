#!/bin/sh

mv bashrc_cadyf $HOME/.bashrc

mkdir -p $HOME/dev/CADYF
mkdir -p $HOME/tmp/CADYF

cd $HOME/dev/CADYF/
svn co file:///home/monet/svndp/repos/CADYF/trunk trunk
cp $HOME/dev/CADYF/trunk/scripts/Config/bash_user_functions $HOME/.bash_user_functions
cd -
