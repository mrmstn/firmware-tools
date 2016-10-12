firmware-tools
==============

OpenWrt firmware patching and repackaging tools - HiWiFi only

### Installation

    # Install required software
    sudo apt-get install build-essential autoconf automake libtool liblzma-dev libglib2.0-dev  # for Ubuntu
    ## sudo yum install gcc make autoconf libtool xz-devel glib2-devel  # for CentOS
      
    # Compile utilities and install
    git clone https://github.com/rssnsj/firmware-tools.git hiwifi-tools -b hiwifi
    cd hiwifi-tools
    make
    make install

### Usage

     hiwifi-repack.sh <model> <ROM_file> [options] ...    patch firmware <ROM_file> and repackage
     hiwifi-repack.sh -c                          clean temporary and target files
     
    Options:
     -o <output_file>          filename of newly built firmware
     -r <package>              remove opkg package (can be multiple)
     -i <package>              install package with ipk file path or URL (can be multiple)
     -e                        enable root login
     -x <commands>             execute commands after all other operations
     -E                        EXTRACT
     -P                        PACK

### Example

    rssnsj@precise-vmx:~/roms$ hiwifi-repack.sh HC5761-xxxx.bin -e -i tcpdump
    >>> Analysing source firmware: HC5761-xxxx.bin ...
    Found SquashFS at 1077084.
    >>> Extracting kernel, rootfs partitions ...
    >>> Extracting SquashFS into directory squashfs-root/ ...
    Parallel unsquashfs: Using 4 processors
    1488 inodes (1502 blocks) to write
      
    [===============================================================================================|] 1502/1502 100%
    created 1259 files
    created 104 directories
    created 228 symlinks
    created 0 devices
    created 0 fifos
    >>> Patching the firmware ...
    Downloading http://downloads.openwrt.org/barrier_breaker/14.07/ramips/mt7620a/packages/base/Packages.gz.
    Inflating http://downloads.openwrt.org/barrier_breaker/14.07/ramips/mt7620a/packages/base/Packages.gz.
    ... ...
    Installing tcpdump (4.5.1-4) to root...
    Downloading http://downloads.openwrt.org/barrier_breaker/14.07/ramips/mt7620a/packages/base/tcpdump_4.5.1-4_ramips_24kec.ipk.
    Installing libpcap (1.5.3-1) to root...
    Downloading http://downloads.openwrt.org/barrier_breaker/14.07/ramips/mt7620a/packages/base/libpcap_1.5.3-1_ramips_24kec.ipk.
    Configuring libpcap.
    Configuring tcpdump.
    Checking init.d scripts for newly installed services ...
    >>> Repackaging the modified firmware ...
    Parallel mksquashfs: Using 1 processor
    Creating 4.0 filesystem on root.squashfs, block size 262144.
    Pseudo file "/dev" exists in source filesystem "/home/rssnsj/roms/squashfs-root/dev".
    Ignoring, exclude it (-e/-ef) to override.
    [===============================================================================================|] 1281/1281 100%
    Exportable Squashfs 4.0 filesystem, xz compressed, data block size 262144
            compressed data, compressed metadata, compressed fragments, compressed xattrs
    ... ...
    Directory table size 15678 bytes (15.31 Kbytes)
            46.62% of uncompressed directory table size (33629 bytes)
    Number of duplicate files found 9
    ... ...
    padding image to 006b0000
    padding image to 006c0000
    >>> Done. New firmware: HC5761-xxxx.bin.out
    rssnsj@precise-vmx:~/roms$
