#
# Copyright (C) 2013 The Android Open Source Project
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
# BoardConfig.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true

TARGET_ARCH := mips64
ifeq (,$(TARGET_ARCH_VARIANT))
TARGET_ARCH_VARIANT := mips64r6
endif
TARGET_CPU_ABI  := mips64

TARGET_2ND_ARCH := mips
ifeq (,$(TARGET_2ND_ARCH_VARIANT))
ifeq ($(TARGET_ARCH_VARIANT),mips64r6)
TARGET_2ND_ARCH_VARIANT :=  mips32r6
else
TARGET_2ND_ARCH_VARIANT :=  mips32r2-fp
endif
endif
TARGET_2ND_CPU_ABI  := mips

# Make TARGET_XXX_CPU_VARIANT the same as TARGET_XXX_ARCH_VARIANT
TARGET_CPU_VARIANT := $(TARGET_ARCH_VARIANT)
TARGET_2ND_CPU_VARIANT := $(TARGET_2ND_ARCH_VARIANT)

# The emulator (qemu) uses the Goldfish devices
HAVE_HTC_AUDIO_DRIVER := true
BOARD_USES_GENERIC_AUDIO := true

# no hardware camera
USE_CAMERA_STUB := true

# Enable dex-preoptimization to speed up the first boot sequence
# of an SDK AVD. Note that this operation only works on Linux for now
ifeq ($(HOST_OS),linux)
  ifeq ($(WITH_DEXPREOPT),)
    WITH_DEXPREOPT := true
  endif
endif

# Build OpenGLES emulation guest and host libraries
BUILD_EMULATOR_OPENGL := true

# Build and enable the OpenGL ES View renderer. When running on the emulator,
# the GLES renderer disables itself if host GL acceleration isn't available.
USE_OPENGL_RENDERER := true

TARGET_USERIMAGES_USE_EXT4 := true
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1342177280  # 1.25 GB swag, 20% more than before
BOARD_USERDATAIMAGE_PARTITION_SIZE := 734003200
BOARD_CACHEIMAGE_PARTITION_SIZE := 69206016
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 512
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true

BOARD_SEPOLICY_DIRS += build/target/board/generic/sepolicy

# Build flags for Wifi Marionette Test
BOARD_WPA_SUPPLICANT_DRIVER := TEST
BOARD_HOSTAPD_DRIVER := TEST
WPA_SUPPLICANT_VERSION := VER_0_8_X

CONFIG_EAP := true
CONFIG_EAP_PEAP := true
CONFIG_EAP_TTLS := true
CONFIG_EAP_TLS := true
