CMAKE_MINIMUM_REQUIRED(VERSION 3.12)


project(k4ProjectTemplate LANGUAGES CXX)

# please keep this layout for version setting, used by the automatic tagging script
set(PACKAGE_VERSION_MAJOR 1)
set(PACKAGE_VERSION_MINOR 2)
set(PACKAGE_VERSION_PATCH 3)

set(PACKAGE_VERSION "${PACKAGE_VERSION_MAJOR}.${PACKAGE_VERSION_MINOR}.${PACKAGE_VERSION_PATCH}")


# dependencies are declared like this
find_package(ROOT COMPONENTS RIO Tree Physics)
find_package(EDM4HEP)
find_package(k4FWCore)
find_package(Gaudi)

#---------------------------------------------------------------

include(cmake/Key4hepConfig.cmake)

include(GNUInstallDirs)

include(CTest)

add_subdirectory(example)

include(cmake/CreateProjectConfig.cmake)


