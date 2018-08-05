#!/bin/bash

######----RESPECT THE VARIABLES-----#####

hardDrive1='/dev/sdb'
hardDrive2='/dev/sdc'


#########--------PUT SOME RESPEC ON LAUNCHING-----------######
echo "starting preinstall requirements"
preInstall
sleep 4
echo "starting drive partitions"
partDrive
sleep 4
echo "creating virtual group"
volgroupSetup
sleep 4
echo "creating logical volumes"
logicalVolEncrypt
sleep 4
echo "prepping boot part"
prepBoot
sleep 4
echo "encrypting root and installing base!"
encryptVolumes
sleep 10
echo "ok ur on ur own now bad boy"

preInstall() {
timedatectl set-ntp true
echo "doing a lol on the drives being used, this will take an hour or something lol"
dd if=/dev/zero of=/dev/sdb status=progress; sync
echo "SSD has finished formatting"
dd if=/dev/zero of=/dev/sdc status=progress; sync
echo "both drives are clean clean clean"
}


partDrive(){
partHD1
partHD2
partHD1(){
echo "partitioning the first drive"
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${hardDrive1}
        m
        n
        p
        1

        +4G
        t
        82
        a
        1
        n
        p
        2


        t
        8e
        w
        q
EOF
echo "root drive partittioend"
}

partHD2(){
echo "partitioning the second drive"
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${hardDrive2}
    m
    n
    p
    1


    t
    8e
    w
    q
EOF
echo "home drive partitioned"
}
fdisk -l
sleep 10
}

volgroupSetup(){
echo "setting up LVMs"
pvcreate /dev/sdb2
echo "root drive created on SSD"
pvcreate /dev/sdc1
echo "home drive created on TB HDD\n"
echo "do we have both disks?, Good for yes notGood for bad!"
pvdisplay
sleep 10
echo "creating logical volumes"
vgcreate volGroup01 /dev/sdb2 /dev/sdc1
echo "Logical volumes made!"
vgdisplay
sleep 5
echo "how we doin? Good for well, lolwtf for bad"
}

logicalVolEncrypt(){
echo "creating logical volumes"
lvcreate -L 2G -n cryptswap volGroup01 /dev/sdb2
echo "created swap vol"
lvcreate -L 4G -n crypttmp volGroup01 /dev/sdb2
mkswap /dev/volGroup01/cryptswap
swapon /dev/volGroup01/cryptswap
echo "created temp vol"
lvcreate -l 100%FREE -n cryptroot volGroup01 /dev/sdb2
echo "created root vol"
lvcreate -l 100%FREE -n crypthome volGroup01 /dev/sdc1
echo "created home vol\n"
echo "how are things looking?, Good for well lolwtf for bad\n"
lvdisplay
sleep 5
}

encryptVolumes(){
echo "encrypting and opening"
echo -n "uaevHoqvwS5" | cryptsetup luksFormat --type luks2 /dev/volGroup01/cryptroot
echo -n "uaevHoqvwS5" | cryptsetup open /dev/volGroup01/cryptroot root
echo "formatting and mounting root"
mkfs.ext4 /dev/mapper/root
mount /dev/mapper/root /mnt
echo "ITS TIME TO I-I-I-I-I-I-INSTALL!!!!!!!"
pacstrap /mnt base
}

prepBoot(){
dd if=/dev/zero of=/dev/sdb1 bs=1M status=progress
mkfs.ext4 /dev/sdb1
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
}

#------------------------------------------------------------------------------------------------
######################################################START STUFF HERE###########################