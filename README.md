# Overview
Deploy trident plugin to k8s cluster with just one click.

# Requirements

1. k8s cluster, with all nodes configured SSH key-based authentication from master node.
2. pssh/pscp installed
3. you may find [this project](https://github.com/wavezhang/pssh-init) helpful to archive this requirements,  :)

# Usage
Only on master node:
1. update variables in config file base on your own
2. run ```init.sh``` to resolve dependency software and settings needed for trident.
3. run ```install.sh``` to install the plugin.
