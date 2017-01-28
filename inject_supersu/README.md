# Steps to get permanent root on Kyocera KC-S701

Be careful! This procedure can brick your phone!

* The `./reboot_into_dload.sh` script will reboot your phone into download mode.
* Fetch original system parition from the phone: `sudo ./read_system_partition.sh`
* Run `sudo ./install_su.sh` script to inject SuperSU into the Kyocera system partition: `19-system-root.img`
* This partition could be flashed into the phone using the command: `sudo ./write_rooted_system.sh`
* When the script is finished reboot the phone using its power button. You have to hold it till vibration.
