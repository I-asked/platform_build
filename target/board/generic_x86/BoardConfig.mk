# config.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true
TARGET_CPU_ABI := x86
TARGET_ARCH := x86
TARGET_ARCH_VARIANT := x86
TARGET_PRELINK_MODULE := false

# The IA emulator (qemu) uses the Goldfish devices
HAVE_HTC_AUDIO_DRIVER := true
BOARD_USES_GENERIC_AUDIO := true

# no hardware camera
USE_CAMERA_STUB := true

# customize the malloced address to be 16-byte aligned
BOARD_MALLOC_ALIGNMENT := 16

# Enable dex-preoptimization to speed up the first boot sequence
# of an SDK AVD. Note that this operation only works on Linux for now
ifeq ($(HOST_OS),linux)
WITH_DEXPREOPT ?= true
endif

# Build OpenGLES emulation host and guest libraries
BUILD_EMULATOR_OPENGL := true

# Build and enable the OpenGL ES View renderer. When running on the emulator,
# the GLES renderer disables itself if host GL acceleration isn't available.
USE_OPENGL_RENDERER := true

TARGET_USERIMAGES_USE_EXT4 := true
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1342177280  # 1.25 GB
BOARD_USERDATAIMAGE_PARTITION_SIZE := 576716800
BOARD_CACHEIMAGE_PARTITION_SIZE := 69206016
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 512
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true

# Build flags for Wifi Marionette Test
BOARD_WPA_SUPPLICANT_DRIVER := TEST
BOARD_HOSTAPD_DRIVER := TEST
WPA_SUPPLICANT_VERSION := VER_0_8_X

CONFIG_EAP := true
CONFIG_EAP_PEAP := true
CONFIG_EAP_TTLS := true
CONFIG_EAP_TLS := true

BOARD_SEPOLICY_DIRS += \
        build/target/board/generic/sepolicy \
        build/target/board/generic_x86/sepolicy
