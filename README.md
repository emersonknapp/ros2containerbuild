# ROS2 Container Builder

This is a Dockerfile to create an image that is a full ROS2 workspace environment - use this for builds so that you don't have to trust your global apt/python environments.

To allow GDB in the container, add arguments `--cap-add=SYS_PTRACE --security-opt seccomp=unconfined`

## Create armhf container

Prereqs

```
apt-get install qemu binfmt-support qemu-user-static
```

Creating the container (from this directory)

```
mkdir bin
cp /usr/bin/qemu* bin
docker build . -f Dockerfile_arm32 -t ros2dev:armhf
```
