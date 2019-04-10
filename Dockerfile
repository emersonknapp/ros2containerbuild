FROM ubuntu:bionic

RUN echo 'Acquire::HTTP::Proxy "http://240.10.0.3:3142";' >> /etc/apt/apt.conf.d/01proxy \
 && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

# set up timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime

# install core dependencies
RUN apt-get update && apt-get install -q -y \
       tzdata \
       locales \
       curl \
       gnupg2 \
       lsb-release \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
RUN locale-gen en_US $LANG && update-locale LC_ALL=$LANG LANG=$LANG

# add ros apt repos
RUN curl http://repo.ros2.org/repos.key | apt-key add - \
    && sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

# Install tools
RUN apt-get update --fix-missing && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3-colcon-common-extensions \
    python3-lark-parser \
    python3-pip \
    python-rosdep \
    python3-vcstool \
    wget \
  && rm -rf /var/lib/apt/lists/*

# install some pip packages needed for testing
RUN python3 -m pip install -U \
  argcomplete \
  flake8 \
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
  pytest-cov \
  pytest-runner \
  setuptools

# install Fast-RTPS dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    libasio-dev \
    libtinyxml2-dev \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt install -y \
  clang \
  libc++-dev \
  libc++abi-dev \
  && rm -rf /var/lib/apt/lists/*

#Setup ROS2 code for compile
WORKDIR /root/ros

# Get a ros2repos for rosdep install, but not to actually use
RUN wget https://raw.githubusercontent.com/ros2/ros2/master/ros2.repos \
    && mkdir src \
    && vcs import src < ros2.repos \
    && rosdep init \
    && apt-get update && rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro crystal -y --skip-keys "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 rti-connext-dds-5.3.1 urdfdom_headers" \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y zsh vim && rm -rf /var/lib/apt/lists/*

# Get mixins - allow for overlay
RUN python3 -m pip install -U colcon-mixin
RUN git clone https://github.com/colcon/colcon-mixin-repository /root/colcon-mixin-repository
RUN colcon mixin add default file:///root/colcon-mixin-repository/index.yaml && colcon mixin update
