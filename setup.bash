setup_rti () {
  cd /opt/rti.com/rti_connext_dds-5.3.1/resource/scripts && source ./rtisetenv_x64Linux3gcc5.4.0.bash; cd -
  export RMW_IMPLEMENTATION=rmw_connext_cpp
}
