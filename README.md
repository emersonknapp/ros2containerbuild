# ROS2 Container Builder

This is a Dockerfile to create an image that is a full ROS2 workspace environment - use this for builds so that you don't have to trust your global apt/python environments.

To allow GDB in the container, add arguments `--cap-add=SYS_PTRACE --security-opt seccomp=unconfined`
