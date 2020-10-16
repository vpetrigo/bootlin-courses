# U-boot uploading

```
=> setenv ipaddr <IP-addr>
=> setenv serverip <IP-addr>
=> dhcp
=> tftp 0x21000000 <IP-addr>:zImage
=> tftp 0x22000000 <IP-addr>:at91-sama5d4_xplained.dtb
=> bootz 0x21000000 - 0x22000000
```

Oneliner:

```
=> setenv bootcmd 'tftp 0x21000000 <IP-addr>:zImage; tftp 0x22000000 <IP-addr>:at91-sama5d4_xplained.dtb; bootz 0x21000000 - 0x22000000'
```

Preparing NAND for flashing zImage and DTB:

```
# for DTB
=> nand erase 0x140000 0x20000
# for zImage
=> nand erase 0x180000 0x500000
```

Flash DTB and zImage

```
# for DTB
=> nand write 0x22000000 0x140000 0x20000
# for zImage
=> nand write 0x21000000 0x180000 0x500000
```

Load DTB and zImage from NAND:

```
# DTB
=> nand read 0x22000000 0x140000 0x20000
# zImage
=> nand read 0x21000000 0x180000 0x500000
# boot
=> bootz 0x21000000 - 0x22000000
# bootcmd
=> setenv bootcmd "nand read 0x22000000 0x140000 0x20000; nand read 0x21000000 0x180000 0x500000; bootz 0x21000000 - 0x22000000"
=> saveenv
```

# NFS setup

Set up NFS in U-boot:

```
=> setenv bootargs console=ttyS0,115200 root=/dev/nfs ip=192.168.4.102:::::eth0 nfsroot=192.168.4.146:/home/vpetrigo/projects/bootlin/emb-linux/embedded-linux-labs/tinysystem/nfsroot,nfsvers=3 rw
```

NFS Fedora 29-33:

```bash
# /etc/nfs.conf
[nfsd]
# debug=0
# threads=8
# host=
# port=0
# grace-time=90
# lease-time=90
udp=y
# tcp=y
# vers2=n
vers3=y
# vers4=y
# vers4.0=y
# vers4.1=y
# vers4.2=y
# rdma=n
#
```

Manual for setting up NFS paths can be found [here](https://fedoraproject.org/wiki/Administration_Guide_Draft/NFS)

# BusyBox

BusyBox static linking size:

```
-rwxr-xr-x. 1 vpetrigo vpetrigo 1132288 Mar 31 02:46 busybox
```

BusyBox dynamic linking size:

```
-rwxrwxr-x. 1 vpetrigo vpetrigo 957036 Apr  2 00:58 ./busybox
```

Set up USB root in U-boot:

```
=> setenv bootargs console=ttyS0,115200 root=/dev/sdb2 rootwait
```

Load from the USB:

```
=> setenv bootcmd 'usb reset; fatload usb 0:1 0x21000000 zImage; fatload usb 0:1 0x22000000 at91-sama5d4_xplained.dtb; bootz 0x21000000 - 0x22000000'
```

# UBIFS

Create UBIFS with the root filesystem:

- the size of one _LEB_ is the size of the _PEB_ minus the size of two page

```
# mkfs.ubifs -m 4096 -e 248KiB -c 66 -r nfsroot/ rootfs.img
```

Create UBIFS flash image:

```
ubinize -o ubi.img -p 256KiB -m 4096 ubinize.cfg
```

U-boot MTDPARTS:

```
=> setenv mtdids nand0=atmel_nand
=> setenv mtdparts mtdparts=atmel_nand:256k(AT91Bootstrap)ro,768k(U-Boot)ro,256k(Env),256k(EnvBak),-(UbiFS)
```

U-boot UBIFS bootargs:

```
# Default
#=> setenv bootargs "console=ttyS0,115200 earlyprintk mtdparts=atmel_nand:256k(bootstrap)ro,768k(uboot)ro,256K(env_redundant),256k(env),512k(dtb),6M(kernel)ro,-(rootfs) rootfstype=ubifs ubi.mtd=6 root=ubi0:rootfs"
# New bootargs
=> setenv bootargs "console=ttyS0,115200 earlyprintk ${mtdparts} rootfstype=ubifs ubi.mtd=4 root=ubi0:rootfs"
=> setenv bootcmd 'mtdparts; ubi part UbiFS; ubi readvol 0x21000000 kernel; ubi readvol 0x22000000 dtb; bootz 0x21000000 - 0x22000000'
```

- in order to enable Ethernet PHY

```
setenv bootargs "console=ttyS0,115200 earlyprintk ${mtdparts} ip=on rootfstype=ubifs ubi.mtd=4 root=ubi0:rootfs"
```

U-boot load UBIFS:

```
=> tftp 0x21000000 ubi.img
# clean up NAND for the UBIFS
=> nand erase.part UbiFS
# write downloaded image
=> nand write 0x21000000 0x180000 ${filesize}
```

## UBIFS block emulation layer

- Enable `CONFIG_MTD_UBI_BLOCK` in the kernel configuration

### Squashfs creation

- `mksquashfs nfsroot/ nfs.sqfs -noappend`

### Squashfs on top of UBIFS

```
#=> setenv bootargs "console=ttyS0,115200 earlyprintk mtdparts=atmel_nand:256k(AT91Bootstrap)ro,768k(U-Boot)ro,256k(Env),256k(EnvBak),-(UbiFS) ubi.mtd=4 ubi.block=0,rootfs root=/dev/ubiblock0_3"
```

## UBIFS atomic update

- with the `kernel-backup` partition the updated `bootargs`:

```
=> setenv bootargs "console=ttyS0,115200 earlyprintk mtdparts=atmel_nand:256k(AT91Bootstrap)ro,768k(U-Boot)ro,256k(Env),256k(EnvBak),-(UbiFS) ubi.mtd=4 ubi.block=0,rootfs r oot=/dev/ubiblock0_4"
```

- [UBIFS FAQ](http://www.linux-mtd.infradead.org/faq/ubifs.html) with `nandsim` module description
- [UBIFS creating and flashing images](https://bootlin.com/blog/creating-flashing-ubi-ubifs-images/) article
- `ubinize.cfg` should be updated properly to support potential kernel/DTB/rootfs images growth (see [`ubinize_update_support.cfg`](nfs_init/ubinize_update_support.cfg))

- U-boot kernel load fallback support:

```
=> setenv boot_main "ubi readvol 0x21000000 kernel; ubi readvol 0x22000000 dtb; bootz 0x21000000 - 0x22000000"
=> setenv boot_backup "ubi readvol 0x21000000 kernel-backup; ubi readvol 0x22000000 dtb; bootz 0x21000000 - 0x22000000"
=> setenv bootcmd "mtdparts; ubi part UbiFS; run boot_main; run boot_backup"
```

# Third party libraries part

- update `bootargs` for mounting NFS filesystem properly

```
=> setenv bootargs console=ttyS0,115200 root=/dev/nfs ip=dhcp nfsroot=192.168.4.147:/home/vpetrigo/projects/bootlin/emb-linux/embedded-linux-labs/thirdparty/target,nfsvers=3 rw
```

- do not forget to update `/etc/exports` and restart `nfs-server` daemon:

```bash
# Relevant for Fedora 29-30
$ sudo systemctl restart nfs-server.service
```
