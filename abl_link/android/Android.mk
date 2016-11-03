LOCAL_PATH := $(call my-dir)

#---------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := pd
LOCAL_EXPORT_C_INCLUDES := ../../PdCore/jni/libpd/pure-data/src
LOCAL_SRC_FILES := ../../PdCore/libs/$(TARGET_ARCH_ABI)/libpd.so
ifneq ($(MAKECMDGOALS),clean)
    include $(PREBUILT_SHARED_LIBRARY)
endif

#---------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := abl_link_tilde
LOCAL_CFLAGS := -DPD -I./external/android-ifaddrs -I./external/link/include -I./external/link/modules/asio-standalone/asio/include -DLINK_PLATFORM_LINUX=1 -DABL_LINK_OFFSET_MS=15
LOCAL_CPPFLAGS := -std=c++11 -Wno-multichar -fexceptions -Werror
LOCAL_SRC_FILES := external/abl_link~.cpp external/abl_link_instance.cpp external/android-ifaddrs/ifaddrs.cpp
LOCAL_SHARED_LIBRARIES = pd
include $(BUILD_SHARED_LIBRARY)

#---------------------------------------------------------------
