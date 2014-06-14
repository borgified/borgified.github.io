tags: pe_r720xd grub.conf dell

system configuration:
12 x 300 GB drives in front
2 x 300 GB drives in back

in hw raid controller:

13 virtual drives

VD 0 (0:0:1)
VD 1 (0:0:2)
2 drives mirrored (the two drives in the back) VD 12
13 of these . ie. VD 0 has one physical disk, VD 1 has one physical disk, etc.

BIOS set to boot: VD 0
(because thats the one w/ the mirrored drives)


grub.conf

boot=/dev/sdm
default=0
timeout=5
splashimage=(hd0,0)/grub/splash.xpm.gz
hiddenmenu
title Red Hat Enterprise Linux (2.6.32-358.el6.x86_64)
        root (hd0,0)
        kernel /vmlinuz-2.6.32-358.el6.x86_64 ro root=UUID=a7ca49b4-8900-4cac-a677-26a1e7246004 rd_NO_LUKS rd_NO_LVM LANG=en_US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet
        initrd /initramfs-2.6.32-358.el6.x86_64.img



