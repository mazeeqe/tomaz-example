# Install script for directory: /afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/example

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "RelWithDebInfo")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so"
         RPATH "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/install/:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-28/x86_64-almalinux9-gcc14.2.0-opt/k4fwcore/1.1.2-7yb5p4/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/edm4hep/0.99.1-zincmm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/root/6.32.04-vms5ij/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/gaudi/38.3-6rlwni/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/boost/1.86.0-4bdqk5/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/intel-tbb/2021.12.0-utctht/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/python/3.11.9-6wq3jm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/podio/1.1-ur2cnz/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/vdt/0.4.4-feme7a/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/sio/0.2-lp6t6f/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE MODULE FILES "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/example/libk4ProjectTemplatePlugins.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so"
         OLD_RPATH "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/.plugins:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-28/x86_64-almalinux9-gcc14.2.0-opt/k4fwcore/1.1.2-7yb5p4/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/edm4hep/0.99.1-zincmm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/root/6.32.04-vms5ij/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/gaudi/38.3-6rlwni/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/boost/1.86.0-4bdqk5/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/intel-tbb/2021.12.0-utctht/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/python/3.11.9-6wq3jm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/podio/1.1-ur2cnz/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/vdt/0.4.4-feme7a/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/sio/0.2-lp6t6f/lib:"
         NEW_RPATH "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/install/:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-28/x86_64-almalinux9-gcc14.2.0-opt/k4fwcore/1.1.2-7yb5p4/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/edm4hep/0.99.1-zincmm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/root/6.32.04-vms5ij/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/gaudi/38.3-6rlwni/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/boost/1.86.0-4bdqk5/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/intel-tbb/2021.12.0-utctht/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/python/3.11.9-6wq3jm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/podio/1.1-ur2cnz/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/vdt/0.4.4-feme7a/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/sio/0.2-lp6t6f/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/k4ProjectTemplate.components")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/python/example" TYPE FILE FILES
    "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/example/genConfDir/example/k4ProjectTemplatePluginsConf.py"
    "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/example/genConfDir/example/__init__.py"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/k4ProjectTemplate.confdb")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/k4ProjectTemplate.confdb2")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "shlib" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so"
         RPATH "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/install/:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-28/x86_64-almalinux9-gcc14.2.0-opt/k4fwcore/1.1.2-7yb5p4/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/edm4hep/0.99.1-zincmm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/root/6.32.04-vms5ij/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/gaudi/38.3-6rlwni/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/boost/1.86.0-4bdqk5/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/intel-tbb/2021.12.0-utctht/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/python/3.11.9-6wq3jm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/podio/1.1-ur2cnz/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/vdt/0.4.4-feme7a/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/sio/0.2-lp6t6f/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE MODULE FILES "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/example/libk4ProjectTemplatePlugins.so")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so"
         OLD_RPATH "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/build/.plugins:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-28/x86_64-almalinux9-gcc14.2.0-opt/k4fwcore/1.1.2-7yb5p4/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/edm4hep/0.99.1-zincmm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/root/6.32.04-vms5ij/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/gaudi/38.3-6rlwni/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/boost/1.86.0-4bdqk5/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/intel-tbb/2021.12.0-utctht/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/python/3.11.9-6wq3jm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/podio/1.1-ur2cnz/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/vdt/0.4.4-feme7a/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/sio/0.2-lp6t6f/lib:"
         NEW_RPATH "/afs/cern.ch/user/c/chensel/ILD/workarea/May2025/Tomaz/install/:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-28/x86_64-almalinux9-gcc14.2.0-opt/k4fwcore/1.1.2-7yb5p4/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/edm4hep/0.99.1-zincmm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/root/6.32.04-vms5ij/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/gaudi/38.3-6rlwni/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/boost/1.86.0-4bdqk5/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/intel-tbb/2021.12.0-utctht/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/python/3.11.9-6wq3jm/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/podio/1.1-ur2cnz/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/vdt/0.4.4-feme7a/lib:/cvmfs/sw.hsf.org/key4hep/releases/2024-10-03/x86_64-almalinux9-gcc14.2.0-opt/sio/0.2-lp6t6f/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libk4ProjectTemplatePlugins.so")
    endif()
  endif()
endif()

