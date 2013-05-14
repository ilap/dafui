set (PKGNAME dafui)
set (PKGNAME_VERSION 0)
set (PKGNAME_SOVERSION 1)

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.18.0" MINIMUM)
include(ValaPrecompile)

configure_file (${CMAKE_SOURCE_DIR}/${PKGNAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.pc)

install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.vapi DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi)
install (FILES ${CMAKE_SOURCE_DIR}/${PKGNAME}.deps DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/)

# set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_FIND_LIBRARY_SUFFIXES .so)

################################################################################
# External Packages definitions.
################################################################################
set (EXTERN_PROJ dafcore)
set (EXTERN_SOURCE_DIR src)

include (ExternalProject)

ExternalProject_Add (${EXTERN_PROJ}
    #PREFIX ../../${EXTERN_PROJ}
    SOURCE_DIR ../../../${EXTERN_PROJ}
    BINARY_DIR ${CMAKE_BINARY_DIR}/${EXTERN_PROJ}/build
    CMAKE_ARGS "-DDO_NOT_BUILD_TEST:string=\""\"
    INSTALL_DIR ""
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    INSTALL_COMMAND ""
)

ExternalProject_Get_Property(${EXTERN_PROJ} BINARY_DIR)
include_directories (${BINARY_DIR}/${EXTERN_SOURCE_DIR})
set (EXTERN_BINARY_DIR ${BINARY_DIR})

################################################################################
# Sources
################################################################################
set (UNIT_TESTS unit_tests)

set (VALA_SOURCES
    Animation/AnimatableAdapter.vala
    Animation/AnimationMode.vala
    Animation/IAnimatable.vala
    Animation/KeyFrame.vala
    Animation/PropertyAnimator.vala
    Animation/TimeLine.vala
    Core/AbstractListModel.vala
    Core/AbstractTreeModel.vala
    Widgets/AbstractDeckLayout.vala
    Widgets/AnimatedDeckLayout.vala
    Widgets/DeckLayout.vala
    Widgets/IDeckLayout.vala
    Widgets/AnimatedCard.vala
    Widgets/Card.vala
    Widgets/ICard.vala
)

set (PKG_DEPS gtk+-3.0 glib-2.0 gee-1.0)
################################################################################

find_package (PkgConfig)
find_package (GObjectIntrospection 0.9.12)
include (GObjectIntrospectionMacros)

pkg_check_modules(DEPS REQUIRED ${PKG_DEPS})

set (CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
add_definitions (${CFLAGS} "-DGETTEXT_PACKAGE=\"dafvalidation\"")
set (LIBS  ${DEPS_LIBRARIES})
set(LIB_PATHS ${DEPS_LIBRARY_DIRS})
link_directories(${LIB_PATHS})

vala_precompile(VALA_C
    ${VALA_SOURCES}
PACKAGES
    ${PKG_DEPS}
    posix
OPTIONS
    --thread
GENERATE_VAPI
    ${PKGNAME}
GENERATE_HEADER
    ${PKGNAME}
CUSTOM_VAPIS
    ${EXTERN_BINARY_DIR}/${EXTERN_SOURCE_DIR}/${EXTERN_PROJ}.vapi
OPTIONS
)

add_library (${PKGNAME} SHARED  ${VALA_C})
target_link_libraries(${PKGNAME} ${LIBS})
target_link_libraries(${PKGNAME} ${EXTERN_BINARY_DIR}/${EXTERN_SOURCE_DIR}/${CMAKE_FIND_LIBRARY_PREFIXES}${EXTERN_PROJ}${CMAKE_FIND_LIBRARY_SUFFIXES})

set_target_properties (${PKGNAME} PROPERTIES
    VERSION ${PKGNAME_VERSION}
    SOVERSION ${PKGNAME_SOVERSION}
)

install (TARGETS ${PKGNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
