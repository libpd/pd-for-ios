# Makefile to build Ableton Link external for Pure Data.
#
# Needs Makefile.pdlibbuilder as helper makefile for platform-dependent build
# settings and rules.
#
# use : make pdincludepath=/path/to/pure-data/src/
#
# The following command will build the external and install the distributable 
# files into a subdirectory called build/abl_link (useful to package later with deken) :
#
# make install pdincludepath=../pure-data/src/ objectsdir=./build

lib.name = abl_link~

class.sources = abl_link~.cpp

shared.sources = abl_link_instance.cpp

# all extra files to be included in binary distribution of the library
datafiles = abl_link~-help.pd README.md GNU-GPL-v2.0.md LICENSE.md

cflags = -std=c++11 -I./link/include/ \
	 -I./link/modules/asio-standalone/asio/include -Wno-multichar
    
suppress-wunused = yes

define forLinux
  cflags += -DLINK_PLATFORM_LINUX=1
endef

define forDarwin
  cflags += -DLINK_PLATFORM_MACOSX=1 -mmacosx-version-min=10.9
endef

# TODO: Windows build untested
define forWindows
  cflags += -DLINK_PLATFORM_WINDOWS=1
endef

include pd-lib-builder/Makefile.pdlibbuilder
