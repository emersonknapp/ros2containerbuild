#!/bin/bash

# Get RTI automatically in the environment so i can just swap impls whenever
pushd /opt/rti.com/rti_connext_dds-5.3.1/resource/scripts && source ./rtisetenv_x64Linux3gcc5.4.0.bash && popd

# On shell start, to get a mounted repo
colcon mixin update
