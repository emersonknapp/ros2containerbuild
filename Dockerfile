from rostooling/setup-ros-docker:ubuntu-focal-latest

run apt-get update && apt-get install -y --no-install-recommends \
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

run python3 -m pip install -U \
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

run mkdir /ros_ws
workdir /ros_ws
copy src/ src/
run apt-get update \
    && rosdep update \
    && rosdep install --from-paths $(colcon list --packages-up-to rosbag2 -p --packages-skip $(colcon list --base-paths src/ros2/rosbag2 -n)) --ignore-src -y --rosdistro rolling --skip-keys "console_bridge fastcdr fastrtps rti-connext-dds-5.3.1 urdfdom_headers"

run apt-get install -y gdb ccache

run colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
run colcon mixin update
