if exists("b:current_syntax") && b:current_syntax != "cmake"
  finish
endif

" Manually load default syntax first to override it.
syn clear
source $VIMRUNTIME/syntax/cmake.vim

syn region cmakeArguments matchgroup=cmakeBraces start="(" end=")"
  \ contains=ALLBUT,cmakeCommand,cmakeCommandConditional,cmakeCommandRepeat
  \ contains=cmakeCommandDeprecated,cmakeArguments,cmakeTodo

syn region cmakeVariableValue matchgroup=cmakeBraces start=/${/ end=/}/
  \ contained oneline
  \ contains=cmakeVariable,cmakeTodo

hi link cmakeArguments Function
hi link cmakeBraces Delimiter
hi link cmakeCommand Keyword
hi link cmakeGeneratorExpressions Special
hi link cmakeProperty Constant
hi link cmakeVariableValue Identifier

hi link cmakeKWExternalProject Type
hi link cmakeKWadd_compile_options Type
hi link cmakeKWadd_custom_command Type
hi link cmakeKWadd_custom_target Type
hi link cmakeKWadd_definitions Type
hi link cmakeKWadd_dependencies Type
hi link cmakeKWadd_executable Type
hi link cmakeKWadd_library Type
hi link cmakeKWadd_subdirectory Type
hi link cmakeKWadd_test Type
hi link cmakeKWbuild_command Type
hi link cmakeKWbuild_name Type
hi link cmakeKWcmake_host_system_information Type
hi link cmakeKWcmake_minimum_required Type
hi link cmakeKWcmake_parse_arguments Type
hi link cmakeKWcmake_policy Type
hi link cmakeKWconfigure_file Type
hi link cmakeKWcreate_test_sourcelist Type
hi link cmakeKWctest_build Type
hi link cmakeKWctest_configure Type
hi link cmakeKWctest_coverage Type
hi link cmakeKWctest_memcheck Type
hi link cmakeKWctest_run_script Type
hi link cmakeKWctest_start Type
hi link cmakeKWctest_submit Type
hi link cmakeKWctest_test Type
hi link cmakeKWctest_update Type
hi link cmakeKWctest_upload Type
hi link cmakeKWdefine_property Type
hi link cmakeKWenable_language Type
hi link cmakeKWexec_program Type
hi link cmakeKWexecute_process Type
hi link cmakeKWexport Type
hi link cmakeKWexport_library_dependencies Type
hi link cmakeKWfile Type
hi link cmakeKWfind_file Type
hi link cmakeKWfind_library Type
hi link cmakeKWfind_package Type
hi link cmakeKWfind_path Type
hi link cmakeKWfind_program Type
hi link cmakeKWfltk_wrap_ui Type
hi link cmakeKWforeach Type
hi link cmakeKWfunction Type
hi link cmakeKWget_cmake_property Type
hi link cmakeKWget_directory_property Type
hi link cmakeKWget_filename_component Type
hi link cmakeKWget_property Type
hi link cmakeKWget_source_file_property Type
hi link cmakeKWget_target_property Type
hi link cmakeKWget_test_property Type
hi link cmakeKWif Type
hi link cmakeKWinclude Type
hi link cmakeKWinclude_directories Type
hi link cmakeKWinclude_external_msproject Type
hi link cmakeKWinclude_guard Type
hi link cmakeKWinstall Type
hi link cmakeKWinstall_files Type
hi link cmakeKWinstall_programs Type
hi link cmakeKWinstall_targets Type
hi link cmakeKWlist Type
hi link cmakeKWload_cache Type
hi link cmakeKWload_command Type
hi link cmakeKWmacro Type
hi link cmakeKWmake_directory Type
hi link cmakeKWmark_as_advanced Type
hi link cmakeKWmath Type
hi link cmakeKWmessage Type
hi link cmakeKWoption Type
hi link cmakeKWproject Type
hi link cmakeKWremove Type
hi link cmakeKWseparate_arguments Type
hi link cmakeKWset Type
hi link cmakeKWset_directory_properties Type
hi link cmakeKWset_property Type
hi link cmakeKWset_source_files_properties Type
hi link cmakeKWset_target_properties Type
hi link cmakeKWset_tests_properties Type
hi link cmakeKWsource_group Type
hi link cmakeKWstring Type
hi link cmakeKWsubdirs Type
hi link cmakeKWtarget_compile_definitions Type
hi link cmakeKWtarget_compile_features Type
hi link cmakeKWtarget_compile_options Type
hi link cmakeKWtarget_include_directories Type
hi link cmakeKWtarget_link_libraries Type
hi link cmakeKWtarget_sources Type
hi link cmakeKWtry_compile Type
hi link cmakeKWtry_run Type
hi link cmakeKWunset Type
hi link cmakeKWuse_mangled_mesa Type
hi link cmakeKWvariable_requires Type
hi link cmakeKWvariable_watch Type
hi link cmakeKWwhile Type
hi link cmakeKWwrite_file Type
