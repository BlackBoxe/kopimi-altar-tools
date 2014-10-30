kopimi-altar-tools
==================

Assorted tools to control a Kopimi Altar


OpenWrt
=======

Build config options
--------------------

```
CONFIG_PACKAGE_block-mount=y
CONFIG_BUSYBOX_CUSTOM=y
CONFIG_BUSYBOX_CONFIG_ASH_RANDOM_SUPPORT=y
CONFIG_BUSYBOX_CONFIG_STTY=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-hfsplus=y
CONFIG_PACKAGE_kmod-fs-vfat=y
CONFIG_PACKAGE_kmod-fuse=y
CONFIG_PACKAGE_kmod-nls-base=y
CONFIG_PACKAGE_kmod-nls-cp437=y
CONFIG_PACKAGE_kmod-nls-cp850=y
CONFIG_PACKAGE_kmod-nls-iso8859-1=y
CONFIG_PACKAGE_kmod-nls-iso8859-15=y
CONFIG_PACKAGE_kmod-nls-utf8=y
CONFIG_PACKAGE_kmod-usb-acm=y
CONFIG_PACKAGE_kmod-usb-serial=y
CONFIG_PACKAGE_kmod-usb-serial-ftdi=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb2=y
```

Installation
------------

1. Copy the build image to the µSD

```
dd if=bin/sunxi/openwrt-sunxi-A10-OLinuXino-Lime-sdcard-vfat-ext4.img of=/dev/sdX
```

2. Sync, eject the µSD

3. Create a 3rd partion on the µSD with your favorite tool

4. Format it to ext4 with a label of your choice

```
mkfs.ext4 -L KOPIMI-DATA /dev/sdX3
```

5. Mount it

```
mkdir /media/KOPIMI-DATA
mount /dev/sdX3 /media/KOPIMI-DATA
```

6. Populate with the code

```
rsync -a ./kopimi-altar-tools/ /media/KOPIMI-DATA/
```


Configuration
-------------

1. Configure auto-mounting of foreign USB sticks

```
uci set fstab.@global[0].anon_mount=1
uci commit
```

2. Configure auto-mounting of KOPIMI partition

```
uci set fstab.kopimi=mount
uci set fstab.kopimi.target=/opt/kopimi
uci set fstab.kopimi.label=KOPIMI-DATA
uci set fstab.kopimi.enabled=1
uci commit

mkdir -p /opt/kopimi
```

3. Restart

```
reboot ; exit
```

4. Install hotplug handler

```
cp -a /opt/kopimi/lib/openwrt/kopimi.hotplug /etc/hotplug.d/block/99-kopimi
```

5. Install init script & enable it

```
cp -a /opt/kopimi/lib/openwrt/kopimi.init /etc/init.d/kopimi
/etc/init.d/kopimi enable
```
