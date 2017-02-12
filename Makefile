EXTRA_CFLAGS += -mfpu=neon
EXTRA_CFLAGS += -D__KERNEL__ -DKERNEL -DCONFIG_KEXEC -march=armv7-a -mtune=cortex-a9
#EXTRA_CFLAGS += -Wno-undef -Wno-unused-variable -D__KERNEL__ -DKERNEL -DCONFIG_KEXEC -march=armv7-a -mtune=cortex-a9
#-Wno-declaration-after-statement

#export PATH=~/android/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin:$PATH

ARCH		= arm
KERNEL ?= ~/all-kernels/msm8974
CONFIG = msm8226_defconfig
CROSS_COMPILE ?= ~/android/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-
LD = $(CROSS_COMPILE)ld
MDIR ?= $(PWD)

CPPFLAGS	=  -I$(KERNEL)/

MODULE_NAME = wlan
#MODULE_NAME = dload_mode

obj-m += $(MODULE_NAME).o
module-objs := $(MODULE_NAME).o

all: module

module:
	ARCH=$(ARCH) LD=$(LD) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KERNEL)/ M=$(MDIR) modules

clean:
	ARCH=$(ARCH) LD=$(LD) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KERNEL)/ M=$(MDIR) clean
	rm -f *.order

prepare:
	ARCH=$(ARCH) LD=$(LD) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KERNEL)/ $(CONFIG)
	ARCH=$(ARCH) LD=$(LD) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KERNEL)/ modules_prepare

kernel:
	ARCH=$(ARCH) LD=$(LD) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KERNEL)/

kernel_clean:
	ARCH=$(ARCH) LD=$(LD) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KERNEL)/ mrproper
	ARCH=$(ARCH) LD=$(LD) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KERNEL)/ clean

push:
	adb push $(MODULE_NAME).ko /data/local/tmp/
	adb shell cp /system/lib/modules/pronto/pronto_wlan.ko /data/local/tmp/orig.ko
	adb shell /data/local/tmp/dirtycow /system/lib/modules/pronto/pronto_wlan.ko /data/local/tmp/$(MODULE_NAME).ko
