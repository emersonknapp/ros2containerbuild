FROM ubuntu:focal

# RUN echo 'Acquire::HTTP::Proxy "http://240.10.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
#  && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

ENV DEBIAN_FRONTEND=noninteractive

# install core dependencies
RUN apt-get update && apt-get install -q -y --no-install-recommends \
       curl \
       gnupg2 \
       wget \
       lsb-release

# add ros apt repos
RUN wget wget --no-check-certificate -qO - https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

# Install build tools
RUN apt-get update --fix-missing && apt-get install -q -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libbullet-dev \
    python3-colcon-common-extensions \
    python3-flake8 \
    python3-pip \
    python3-pytest-cov \
    python3-rosdep \
    python3-setuptools \
    python3-vcstool \
    wget

# install some pip packages needed for testing
RUN python3 -m pip install -U \
  argcomplete \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest \
  setuptools

# install Fast-RTPS dependencies
RUN apt-get update && apt-get install -q --no-install-recommends -y \
    libasio-dev \
    libtinyxml2-dev \
    libcunit1-dev

# RUN apt-get update && apt install -y \
#   clang \
#   libc++-dev \
#   libc++abi-dev \
#   && rm -rf /var/lib/apt/lists/*

# Enable debug packages
# RUN apt-get update && apt-get install ubuntu-dbgsym-keyring && rm -rf /var/lib/apt/lists/*
# RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" > /etc/apt/sources.list.d/ddebs.list && \
#     echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" > /etc/apt/sources.list.d/ddebs.list

#Setup ROS2 code for compile
WORKDIR /root/ros

# Get a ros2repos for rosdep install, but not to actually use
RUN wget https://raw.githubusercontent.com/ros2/ros2/master/ros2.repos \
    && mkdir src \
    && vcs import src < ros2.repos \
    && rosdep init \
    && apt-get update && rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro rolling -y --skip-keys "console_bridge fastcdr fastrtps rti-connext-dds-5.3.1 urdfdom_headers"

# RUN apt-get update && apt-get install -y zsh vim && rm -rf /var/lib/apt/lists/*
# RUN apt-get update && RTI_NC_LICENSE_ACCEPTED=yes apt-get install -y rti-connext-dds-5.3.1 && rm -rf /var/lib/apt/lists/*

# Get mixins - allow for overlay
RUN python3 -m pip install -U colcon-mixin
RUN git clone https://github.com/colcon/colcon-mixin-repository /root/colcon-mixin-repository
RUN colcon mixin add default file:///root/colcon-mixin-repository/index.yaml && colcon mixin update

# RUN apt-get update && apt-get install -y gdb && rm -rf /var/lib/apt/lists/*

COPY setup.bash /root/rosdev_setup.bash
RUN echo "source ~/rosdev_setup.bash" >> /root/.bashrc

# Enable source packages
# TODO uncomment deb-src lines
# Do this last
