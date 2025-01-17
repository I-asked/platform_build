#
# Copyright (C) 2006 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Configuration for Darwin (Mac OS X) on x86.
# Included by combo/select.mk

$(combo_2nd_arch_prefix)HOST_GLOBAL_CFLAGS += -m32
$(combo_2nd_arch_prefix)HOST_GLOBAL_LDFLAGS += -m32

ifneq ($(strip $(BUILD_HOST_static)),)
# Statically-linked binaries are desirable for sandboxed environment
$(combo_2nd_arch_prefix)HOST_GLOBAL_LDFLAGS += -static
endif # BUILD_HOST_static

# Workaround differences in inttypes.h between host and target.
# See bug 12708004.
$(combo_2nd_arch_prefix)HOST_GLOBAL_CFLAGS += -D__STDC_FORMAT_MACROS -D__STDC_CONSTANT_MACROS

build_mac_version := $(shell sw_vers -productVersion)

mac_sdk_versions_supported :=  10.6 10.7 10.8 10.9
ifneq ($(strip $(MAC_SDK_VERSION)),)
mac_sdk_version := $(MAC_SDK_VERSION)
ifeq ($(filter $(mac_sdk_version),$(mac_sdk_versions_supported)),)
$(warning ****************************************************************)
$(warning * MAC_SDK_VERSION $(MAC_SDK_VERSION) isn't one of the supported $(mac_sdk_versions_supported))
$(warning ****************************************************************)
$(error Stop.)
endif
else
mac_sdk_versions_installed := $(shell xcodebuild -showsdks | grep macosx | sort | sed -e "s/.*macosx//g")
mac_sdk_version := $(firstword $(filter $(mac_sdk_versions_installed), $(mac_sdk_versions_supported)))
ifeq ($(mac_sdk_version),)
mac_sdk_version := $(firstword $(mac_sdk_versions_supported))
endif
endif

mac_sdk_path := $(shell xcode-select -print-path)
# try /Applications/Xcode*.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.?.sdk
#  or /Volume/Xcode/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.?.sdk
mac_sdk_root := $(mac_sdk_path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$(mac_sdk_version).sdk
ifeq ($(wildcard $(mac_sdk_root)),)
# try legacy /Developer/SDKs/MacOSX10.?.sdk
mac_sdk_root := /Developer/SDKs/MacOSX$(mac_sdk_version).sdk
endif
ifeq ($(wildcard $(mac_sdk_root)),)
$(warning *****************************************************)
$(warning * Can not find SDK $(mac_sdk_version) at $(mac_sdk_root))
$(warning *****************************************************)
$(error Stop.)
endif

include $(BUILD_COMBOS)/mac_version.mk

$(combo_2nd_arch_prefix)HOST_TOOLCHAIN_ROOT := prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1
$(combo_2nd_arch_prefix)HOST_TOOLCHAIN_PREFIX := $($(combo_2nd_arch_prefix)HOST_TOOLCHAIN_ROOT)/bin/i686-apple-darwin$(gcc_darwin_version)
$(combo_2nd_arch_prefix)HOST_CC  := $($(combo_2nd_arch_prefix)HOST_TOOLCHAIN_PREFIX)-gcc
$(combo_2nd_arch_prefix)HOST_CXX := $($(combo_2nd_arch_prefix)HOST_TOOLCHAIN_PREFIX)-g++

# gcc location for clang; to be updated when clang is updated
# HOST_TOOLCHAIN_ROOT is a Darwin-specific define
$(combo_2nd_arch_prefix)HOST_TOOLCHAIN_FOR_CLANG := $($(combo_2nd_arch_prefix)HOST_TOOLCHAIN_ROOT)

$(combo_2nd_arch_prefix)HOST_AR := $(AR)

$(combo_2nd_arch_prefix)HOST_GLOBAL_CFLAGS += -isysroot $(mac_sdk_root) -mmacosx-version-min=$(mac_sdk_version) -DMACOSX_DEPLOYMENT_TARGET=$(mac_sdk_version)
$(combo_2nd_arch_prefix)HOST_GLOBAL_CPPFLAGS += -isystem $(mac_sdk_path)/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1
$(combo_2nd_arch_prefix)HOST_GLOBAL_LDFLAGS += -isysroot $(mac_sdk_root) -Wl,-syslibroot,$(mac_sdk_root) -mmacosx-version-min=$(mac_sdk_version)

$(combo_2nd_arch_prefix)HOST_GLOBAL_CFLAGS += -fPIC -funwind-tables
$(combo_2nd_arch_prefix)HOST_NO_UNDEFINED_LDFLAGS := -Wl,-undefined,error

$(combo_2nd_arch_prefix)HOST_SHLIB_SUFFIX := .dylib
$(combo_2nd_arch_prefix)HOST_JNILIB_SUFFIX := .jnilib

# TODO: add AndroidConfig.h for darwin-x86_64
$(combo_2nd_arch_prefix)HOST_GLOBAL_CFLAGS += \
    -include $(call select-android-config-h,darwin-x86)

ifneq ($(filter 10.7 10.7.% 10.8 10.8.% 10.9 10.9.%, $(build_mac_version)),)
       $(combo_2nd_arch_prefix)HOST_RUN_RANLIB_AFTER_COPYING := false
else
       $(combo_2nd_arch_prefix)HOST_RUN_RANLIB_AFTER_COPYING := true
       PRE_LION_DYNAMIC_LINKER_OPTIONS := -Wl,-dynamic
endif

$(combo_2nd_arch_prefix)HOST_GLOBAL_ARFLAGS := cqs

############################################################
## Macros after this line are shared by the 64-bit config.

HOST_CUSTOM_LD_COMMAND := true

define transform-host-o-to-shared-lib-inner
$(hide) $(PRIVATE_CXX) \
        -dynamiclib -single_module -read_only_relocs suppress \
        $($(PRIVATE_2ND_ARCH_VAR_PREFIX)HOST_GLOBAL_LD_DIRS) \
        $(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
            $(PRIVATE_HOST_GLOBAL_LDFLAGS) \
        ) \
        $(PRIVATE_ALL_OBJECTS) \
        $(addprefix -force_load , $(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
        $(PRIVATE_LDLIBS) \
        -o $@ \
        -install_name @rpath/$(notdir $@) \
        -Wl,-rpath,@loader_path/../$(notdir $($(PRIVATE_2ND_ARCH_VAR_PREFIX)HOST_OUT_SHARED_LIBRARIES)) \
        -Wl,-rpath,@loader_path/$(notdir $($(PRIVATE_2ND_ARCH_VAR_PREFIX)HOST_OUT_SHARED_LIBRARIES)) \
        $(PRIVATE_LDFLAGS)
endef

define transform-host-o-to-executable-inner
$(hide) $(PRIVATE_CXX) \
        -Wl,-rpath,@loader_path/../$(notdir $($(PRIVATE_2ND_ARCH_VAR_PREFIX)HOST_OUT_SHARED_LIBRARIES)) \
        -Wl,-rpath,@loader_path/$(notdir $($(PRIVATE_2ND_ARCH_VAR_PREFIX)HOST_OUT_SHARED_LIBRARIES)) \
        -o $@ \
        -Wl,-headerpad_max_install_names \
        $($(PRIVATE_2ND_ARCH_VAR_PREFIX)HOST_GLOBAL_LD_DIRS) \
        $(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
           $(PRIVATE_HOST_GLOBAL_LDFLAGS) \
        ) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
        $(PRIVATE_ALL_OBJECTS) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
        $(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
        $(PRIVATE_LDFLAGS) \
        $(PRIVATE_LDLIBS)
endef

# $(1): The file to check
define get-file-size
stat -f "%z" $(1)
endef
