#!/bin/bash

MassStorage1=/home/pi/lolusb.img
MassStorage2=/home/pi/usbdrive.img

function dd_create {
#Mass storage disk creator, just a raw image 
#TODO
echo "under construction"
}
function prepare_to_switch {
echo -n 0 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role ; modprobe -r {g_mass_storage,g_ether}
}
function apply_choise {
case $choice in
 1)
    prepare_to_switch ; modprobe g_ether iProduct=opizero iManufacturer= dev_addr=62:ef:11:22:11:22 host_addr=ea:c9:35:d4:66:87 use_eem=0 ; echo -n 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role;;
 2)
    prepare_to_switch ; modprobe g_mass_storage file=$MassStorage1 stall=0 ; echo -n 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role;;
 3)
    prepare_to_switch ; modprobe g_mass_storage file=$MassStorage2 stall=0 ; echo -n 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role;;
 4)
    prepare_to_switch;;
esac
}
DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
$DIALOG --clear --title "Otg" \
        --menu "Выберите режим otg:" 12 50 10 \
        "1"  "usb ethernet" \
        "2"  "usb public" \
        "3"  "usb crypted" \
	"4"  "stop otg" 2> $tempfile

retval=$?
choice=`cat $tempfile`
case $retval in
  0)
    apply_choise;;
  1)
    echo "Отказ от ввода.";;
  255)
    echo "Нажата клавиша ESC.";;
esac