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

1. Configure auto-mounting of foreign USB sticks

```
uci set fstab.@global[0].anon_mount=1
uci commit
```

2. Configure auto-mounting of KOPIMI partition

```
uci set fstab.kopimi=mount
uci set fstab.kopimi.target=/opt/kopimi
uci set fstab.kopimi.label=KOPIMI
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
cp -a /opt/kopimi/lib/openwrt/kopimi.hotplug /etc/hotplug.d/99-kopimi-altar-tools
```

5. Install init script & enable it

```
cp -a /opt/kopimi/lib/openwrt/kopimi.init /etc/init.d/kopimi
/etc/init.d/kopimi enable
```
