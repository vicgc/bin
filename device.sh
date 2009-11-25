#!/bin/bash

usage() {

cat << EOF
usage: $0 [options] action device_name

This script permits interaction with devices. Devices are identified by user
selected names making it convenient when working with devices like USB hard
drives that get a different linux kernal device name every time they are
plugged in.

OPTIONS:

-h      Print this help message.

NOTES:

ACTIONS:

    info        Print info about device.
    mount       Mount the device.
    umount      Unmount the device.

EXAMPLES:

    $0 info wdp
    $0 mount wdp
    $0 umount wdp

NOTES:

    Devices are identified by vendor, model and serial number. This info is
    hardcoded within this script.
EOF
}

PRINT_FMT="%-10s %-4s %-10s %-15s %-30s %-10s\n"

declare -a attr
attr[1]='vendor'
attr[2]='model'
attr[3]='serial'

# To a add a new device:
# 1. Determine a code name for it and add to the "names" array.
# 2. Declare an array with the same code name, and set the identification
#    information.
#    Obtain identification info as follows
#
#    Plug in the drive and determine the device.
#    $ fdisk -l
#
#    Get the vendor, model and serial number with this commands. Replace
#    /dev/sda with the path of the device.
#
#    $ udevadm info -a -p `udevadm info -q path -n /dev/sdb` | grep vendor | head -1
#    $ udevadm info -a -p `udevadm info -q path -n /dev/sdb` | grep model | head -1
#    $ udevadm info -a -p `udevadm info -q path -n /dev/sdb` | grep serial | head -1
#

declare -a names
names[1]='ata'
names[2]='sdc'
names[3]='wdp'

# Generic ATA 73GB Internal HDD (ata)
declare -a ata
ata[1]='ATA     '
ata[2]='ST98823AS       '
ata[3]=''

# SanDisk U3 Cruzer 4GB USB Stick (sdc)
declare -a sdc
sdc[1]='SanDisk'
sdc[2]='U3 Cruzer Micro '
sdc[3]='00001619C1717280'

# Western Digital Passport III 320GB USB drive (wdp)
declare -a wdp
wdp[1]='WD'
wdp[2]='Passport III    '
wdp[3]='57442D575845353038443231393234'

declare -a devices

declare -a device_to_name
declare -a name_to_device

#
# set_devices
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#   Get existing devices and populate arrays.
#
# Notes:
#
#   Populates these arrays
#   devices
#   device_to_name
#   name_to_device
#
function set_devices {

    count=1
    for x in /sys/block/sd?; do
        devices[$count]=$(basename $x)"1"
        count=$(( $count +1 ))
    done

    for key in ${!devices[@]}; do
        partition=${devices[$key]}
        device=${partition:0:3}
        vendor=$(udevadm info --query=path --path=/block/$device --attribute-walk | grep vendor | head -1 | awk -F'==' '{print $2}' | tr -d '"')
        model=$(udevadm info --query=path --path=/block/$device --attribute-walk  | grep model  | head -1 | awk -F'==' '{print $2}' | tr -d '"')
        serial=$(udevadm info --query=path --path=/block/$device --attribute-walk | grep serial | head -1 | awk -F'==' '{print $2}' | tr -d '"')

        #  echo "key: $key"
        #  echo "partition: $partition"
        #  echo "device: $device"
        #  echo "vendor: $vendor"
        #  echo "model: $model"
        #  echo "serial: $serial"

        for i in ${!names[@]}; do
            fail=
            name=${names[$i]}
            for j in ${!attr[@]}; do
                dv=$(eval echo \${${attr[$j]}})
                nv=$(eval echo \${$name[$j]})
                if [[ "$dv" != "$nv" ]]; then
                    fail=1
                fi
                # echo "key: $key, i: $i, j: $j, dv: $dv,  nv: $nv, fail: $fail"
            done

            if [[ -z $fail ]]; then
                device_to_name[$key]=$i
                name_to_device[$i]=$key
            fi
        done
    done

    return
}


#
# attr_key_from_name
#
# Sent: attribute name eg vendor
# Return: echoes key number, eg 1
# Purpose:
#
#   Determine the key number given an attribute name.
#
function attr_key_from_name {

    name=$1

    [[ -z $name ]] && return

    key=
    for i in ${!attr[@]}; do
        if [[ "${attr[$i]}" == "$name" ]]; then
            key=$i
        fi
    done

    echo $key

    return
}


#
# name_from_device
#
# Sent: device eg sdb1
# Return: echoes name, eg wdp
# Purpose:
#
#   Determine the name given the device.
#
function name_from_device {

    device=$1

    [[ -z $device ]] && return

    name=
    for key in ${!devices[@]}; do
        if [[ "$device" == "${devices[$key]}" ]]; then
            name=${names[${device_to_name[$key]}]}
        fi
    done

    echo $name

    return
}

#
# device_from_name
#
# Sent: name eg wdp
# Return: echoes device, eg sdb1
# Purpose:
#
#   Determine the device given the name.
#
function device_from_name {

    name=$1

    [[ -z $name ]] && return

    device=
    for key in ${!names[@]}; do
        if [[ "$name" == "${names[$key]}" ]]; then
            device=${devices[${name_to_device[$key]}]}
        fi
    done

    echo $device

    return
}


#
# print_all
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#   Print info about all devices.
#
function print_all {

    for device in ${devices[@]}; do
        print_device $device
    done

    return
}


#
# print_device
#
# Sent: device eg sdb1
# Return: nothing
# Purpose:
#
#   Print info about device.
#
function print_device {

    device=$1

    [[ -z $device ]] && return

    dev="/dev/$device"
    name=$(name_from_device $device)

    vendor=$(eval echo \${$name[$(attr_key_from_name vendor)]})
    model=$(eval echo \${$name[$(attr_key_from_name model)]})
    serial=$(eval echo \${$name[$(attr_key_from_name serial)]})

    mount=$(cat /etc/mtab | awk -v dev="/dev/$device" '$1 ~ dev {print $2}' )

    printf "$PRINT_FMT" $dev $name "$vendor" "$model" "$serial" $mount

    return
}


#
# print_header
#
# Sent: nothing
# Return: nothing
# Purpose:
#
#   Print the header.
#
function print_header {

    printf "$PRINT_FMT" "Device" "Name" "Vendor" "Model" "Serial #" "Mount"

    return
}


#
# info
#
# Sent: name eg wdp optional
# Return: nothing
# Purpose:
#
#   Print info about device associated with name.
#   The name is optional. If not provided, all devices are printed.
#
function info {

    name=$1

    print_header

    if [[ -n $name ]]; then
        print_device $(device_from_name $name)
    else
        print_all
    fi

    return
}


#
# do_mount
#
# Sent: name eg wdp
# Return: nothing
# Purpose:
#
#   Mount the device associated with the name.
#
function do_mount {

    name=$1

    if [[ -z $name ]]; then
        echo "Invalid device name" >&2
        return
    fi

    device=$(device_from_name $name)

    dev_dir="/dev/$device"
    mnt_dir="/mnt/$name"

    mkdir -p $mnt_dir

    cmd="mount -v -t ext3 $dev_dir $mnt_dir"
    echo $cmd
    $cmd

    return
}


#
# do_umount
#
# Sent: name eg wdp
# Return: nothing
# Purpose:
#
#   Unmount the device associated with the name.
#
function do_umount {

    name=$1

    if [[ -z $name ]]; then
        echo "Invalid device name" >&2
        return
    fi

    mnt_dir="/mnt/$name"

    cmd="umount $mnt_dir"
    echo $cmd
    while $cmd > /dev/null 2>&1; do :; done

    return
}


while getopts "h" options; do
  case $options in

    h ) usage
        exit 0;;
    \?) usage
        exit 1;;
    * ) usage
        exit 1;;

  esac
done

shift $(($OPTIND - 1))

if [[ "$#" -lt "1" ]]; then
    usage
    exit 1
fi

set_devices

action=$1
name=$2

case $action in

    info)   info "$name";;
    mount)  do_mount "$name";;
    umount) do_umount "$name";;

    *) usage
       exit 1;;

esac
