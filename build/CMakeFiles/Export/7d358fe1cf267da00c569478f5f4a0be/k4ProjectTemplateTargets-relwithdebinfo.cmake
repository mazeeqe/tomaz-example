#----------------------------------------------------------------
# Generated CMake target import file for configuration "RelWithDebInfo".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "k4ProjectTemplate::k4ProjectTemplatePlugins" for configuration "RelWithDebInfo"
set_property(TARGET k4ProjectTemplate::k4ProjectTemplatePlugins APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(k4ProjectTemplate::k4ProjectTemplatePlugins PROPERTIES
  IMPORTED_COMMON_LANGUAGE_RUNTIME_RELWITHDEBINFO ""
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/lib/libk4ProjectTemplatePlugins.so"
  IMPORTED_NO_SONAME_RELWITHDEBINFO "TRUE"
  )

list(APPEND _cmake_import_check_targets k4ProjectTemplate::k4ProjectTemplatePlugins )
list(APPEND _cmake_import_check_files_for_k4ProjectTemplate::k4ProjectTemplatePlugins "${_IMPORT_PREFIX}/lib/libk4ProjectTemplatePlugins.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
