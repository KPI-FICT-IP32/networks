# Download kernel sources
# =======================
cd /
fetch ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/11.1-RELEASE/src.txz
tar -xjpf src.txz
rm src.txz

# We will need a lot of free space to compile kernel, so clean it up
# ==================================================================

# Move everything possible out of /usr disk
# In order to preserve the system work, mount it back via nullfs
mkdir /tmp/usr/
cp -r /usr/lib /tmp/usr/lib
rm -rf /usr/lib/*
mount -t nullfs /tmp/usr/lib/ /usr/lib

mkdir -p /var/tmp/usr/
cp -r /usr/bin /var/tmp/usr/bin
rm -rf /usr/bin/*
mount -t nullfs /var/tmp/usr/bin/ /usr/bin/

mkdir -p /root/usr/share/
mv /usr/share/i18n/ /root/usr/share/i18n
mv /usr/share/locale/ /root/usr/share/locale
mv /usr/share/misc /root/usr/share/misc
mv /usr/share/dict /root/usr/share/dict
mv /usr/share/doc /root/usr/share/doc
mv /usr/share/groff_font/ /root/usr/share/groff_font
mv /usr/share/games /root/usr/share/games
mv /usr/share/examples /root/usr/share/examples
mv /usr/share/zoneinfo /root/usr/share/zoneinfo
mv /usr/share/openssl /root/usr/share/openssl
mv /usr/share/syscons /root/usr/share/syscons
mv /usr/share/nls /root/usr/share/nls
mv /usr/share/vt /root/usr/share/vt
mv /usr/share/sendmail /root/usr/share/sendmail

mkdir /usr/share/i18n /usr/share/locale /usr/share/misc /usr/share/dict /usr/share/doc /usr/share/groff_font /usr/share/games /usr/share/examples /usr/share/zoneinfo /usr/share/openssl /usr/share/syscons /usr/share/nls /usr/share/vt /usr/share/sendmail
mount -t nullfs /root/usr/share/dict/ /usr/share/dict
mount -t nullfs /root/usr/share/doc/ /usr/share/doc/
mount -t nullfs /root/usr/share/examples/ /usr/share/examples/
mount -t nullfs /root/usr/share/games/ /usr/share/examples/
mount -t nullfs /root/usr/share/groff_font/ /usr/share/groff_font/
mount -t nullfs /root/usr/share/i18n/ /usr/share/i18n/
mount -t nullfs /root/usr/share/locale/ /usr/share/locale/
mount -t nullfs /root/usr/share/misc /usr/share/misc/
mount -t nullfs /root/usr/share/nls /usr/share/nls
mount -t nullfs /root/usr/share/openssl /usr/share/openssl
mount -t nullfs /root/usr/share/sendmail/ /usr/share/sendmail/
mount -t nullfs /root/usr/share/syscons/ /usr/share/syscons/
mount -t nullfs /root/usr/share/vt /usr/share/vt/
mount -t nullfs /root/usr/share/zoneinfo/ /usr/share/zoneinfo/

# Man is too big. Remove all locales except en.UTF-8
cd /usr/share/man/
rm -rf ./en.ISO8859-1 ./en.ISO8859-15
cp -r /usr/share/man/ /tmp/usr/share/man/
rm -rf /usr/share/man/*
mount -t nullfs /tmp/usr/share/man/ /usr/share/man

# Delete sources for architectures we will not need
cd /usr/src/sys/
rm -rf arm64/ arm mips pc98/ powerpc/ sparc64/

# Configure and compile kernel
# ============================
cd /usr/src/
cat >/usr/src/sys/amd64/conf/kernel05 <<EOF
cpu     HAMMER
ident       kernel05

makeoptions WITH_CTF=1                  # Run ctfconvert(1) for DTrace support

options     SCHED_ULE                   # ULE scheduler
options     PREEMPTION                  # Enable kernel thread preemption
options     INET                        # InterNETworking
options     INET6                       # IPv6 communications protocols
options     IPSEC                       # IP (v4/v6) security
options     TCP_OFFLOAD                 # TCP offload
options     SCTP                        # Stream Control Transmission Protocol
options     FFS                         # Berkeley Fast Filesystem
options     SOFTUPDATES                 # Enable FFS soft updates support
options     UFS_ACL                     # Support for access control lists
options     UFS_DIRHASH                 # Improve performance on big directories
options     UFS_GJOURNAL                # Enable gjournal-based UFS journaling
options     QUOTA                       # Enable disk quotas for UFS
options     MD_ROOT                     # MD is a potential root device
options     PROCFS                      # Process filesystem (requires PSEUDOFS)
options     PSEUDOFS                    # Pseudo-filesystem framework
options     GEOM_PART_GPT               # GUID Partition Tables.
options     GEOM_LABEL                  # Provides labelization
options     SCSI_DELAY=5000             # Delay (in ms) before probing SCSI
options     KTRACE                      # ktrace(1) support
options     STACK                       # stack(9) support
options     SYSVSHM                     # SYSV-style shared memory
options     SYSVMSG                     # SYSV-style message queues
options     SYSVSEM                     # SYSV-style semaphores
options     _KPOSIX_PRIORITY_SCHEDULING # POSIX P1003_1B real-time extensions
options     PRINTF_BUFR_SIZE=128        # Prevent printf output being interspersed.
options     KBD_INSTALL_CDEV            # install a CDEV entry in /dev
options     HWPMC_HOOKS                 # Necessary kernel hooks for hwpmc(4)
options     AUDIT                       # Security event auditing
options     CAPABILITY_MODE             # Capsicum capability mode
options     CAPABILITIES                # Capsicum capabilities
options     MAC                         # TrustedBSD MAC Framework
options     KDTRACE_FRAME               # Ensure frames are compiled in
options     KDTRACE_HOOKS               # Kernel DTrace hooks
options     DDB_CTF                     # Kernel ELF linker loads CTF data
options     INCLUDE_CONFIG_FILE         # Include this file in kernel
options     RACCT                       # Resource accounting framework
options     RACCT_DEFAULT_TO_DISABLED   # Set kern.racct.enable=0 by default
options     RCTL                        # Resource limits

# Debugging support.  Always need this:
options     KDB                         # Enable kernel debugger support.
options     KDB_TRACE                   # Print a stack trace for a panic.

# Make an SMP-capable kernel by default
options     SMP                         # Symmetric MultiProcessor Kernel
options     DEVICE_NUMA                 # I/O Device Affinity
options     EARLY_AP_STARTUP

# CPU frequency control
device      cpufreq

# Bus support.
device      acpi
options     ACPI_DMAR
device      pci

# ATA controllers
device      ahci                        # AHCI-compatible SATA controllers
device      ata                         # Legacy ATA/SATA controllers

# ATA/SCSI peripherals
device      scbus                       # SCSI bus (required for ATA/SCSI)
device      ch                          # SCSI media changers
device      da                          # Direct Access (disks)
device      cd                          # CD
device      pass                        # Passthrough device (direct ATA/SCSI access)
device      ses                         # Enclosure Services (SES and SAF-TE)
#device     ctl                         # CAM Target Layer

# NVM Express (NVMe) support
device      nvme                        # base NVMe driver
device      nvd                         # expose NVMe namespaces as disks, depends on nvme

# atkbdc0 controls both the keyboard and the PS/2 mouse
device      atkbdc                      # AT keyboard controller
device      atkbd                       # AT keyboard
device      psm                         # PS/2 mouse

device      kbdmux                      # keyboard multiplexer

device      vga                         # VGA video card driver
options     VESA                        # Add support for VESA BIOS Extensions (VBE)

# TODO: can I remove this?
device      splash                      # Splash screen and screen saver support

# syscons is the default console driver, resembling an SCO console
device      sc
options     SC_PIXEL_MODE               # add support for the raster text mode

# vt is the new video console driver
device      vt
device      vt_vga
device      vt_efifb

# TODO: can I remove this?
device      agp                         # support several AGP chipsets

# PCI Ethernet NICs.
device      em                          # Intel PRO/1000 Gigabit Ethernet Family

# Pseudo devices.
device      loop                        # Network loopback
device      random                      # Entropy device
device      padlock_rng                 # VIA Padlock RNG
device      rdrand_rng                  # Intel Bull Mountain RNG
device      ether                       # Ethernet support
device      tun                         # Packet tunnel.
device      md                          # Memory "disks"
device      gif                         # IPv6 and IPv4 tunneling
device      firmware                    # firmware assist module

# The `bpf' device enables the Berkeley Packet Filter.
# Be aware of the administrative consequences of enabling this!
# Note that 'bpf' is required for DHCP.
device      bpf                         # Berkeley packet filter

# TODO: Can I remove this?
# VirtIO support
device      virtio                      # Generic VirtIO bus (required)
device      virtio_pci                  # VirtIO PCI device
device      vtnet                       # VirtIO Ethernet device
device      virtio_blk                  # VirtIO Block device
device      virtio_scsi                 # VirtIO SCSI device
device      virtio_balloon              # VirtIO Memory Balloon device

# Netmap provides direct access to TX/RX rings on supported NICs
device      netmap                      # netmap(4) support

# The crypto framework is required by IPSEC
device      crypto                      # Required by IPSEC
EOF

# Finally build the kernel. 
# Do not forget to cross fingers
make buildkernel KERNCONF=kernel05

# Put moved content back to /usr
# ==============================
umount /root/usr/share/*
mv /root/usr/share/* /usr/share/
rm -rf /root/usr/
umount /tmp/usr/share/man/
mv /tmp/usr/share/man/ /usr/share/

# After we freed some space in root filesystem (/)
# we can install the built kernel
# ================================================

cd /usr/src/
make installkernel KERNCONF=kernel05

# Clean up build directories
# ==========================

make clean
make cleandepend
make cleandir
make cleanworld

# Finish putting things back where they belong
# ============================================

umount /tmp/usr/lib/
mv /tmp/usr/lib/* /usr/lib
rm -rf /tmp/usr

umount /var/tmp/usr/bin/
mv /var/tmp/usr/bin/* /usr/bin/
rm -rf /var/tmp/usr

# Reboot with the new kernel
# ==========================

reboot
