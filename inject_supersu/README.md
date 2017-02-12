# Steps to get permanent root on Kyocera KYL22 (IQX KEN)

**Be careful! This procedure can brick your phone!**

**These scripts were tested on 100.0.0910 firmware**

**Don't run OTA updates after you've installed SuperSU! This will brick your phone!**

* Download SuperSU ZIP archive: http://www.supersu.com/download
* Download Busybox ZIP archive: https://forum.xda-developers.com/android/software-hacking/tool-busybox-flashable-archs-t3348543
* The `./read_system_partition.sh` script will read system partition into `16-system.img` file.
* The `./disable_mmc_protection.sh` will disable mmc protection of the `system` partition.
* Run `sudo ./install_su.sh` script to inject SuperSU into the Kyocera system partition: `16-system-root.img`
* This partition could be flashed into the phone using the command: `./write_rooted_system.sh`
* When the script is finished, reboot the phone: `adb reboot`
* You'll get installed SuperSU.

# Licence

`mmc_protect.ko` was compiled using this source code: https://github.com/hiikezoe/android_mmc_protect which is licensed under GPLv2.
