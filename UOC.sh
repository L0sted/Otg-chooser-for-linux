#!/bin/bash

MassStorage1=/home/pi/FirstUSB.img
MassStorage2=/home/pi/SecondUSB.img

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
 0)
    prepare_to_switch;;
 1)
    prepare_to_switch ; modprobe g_ether iProduct=opi iManufacturer=Losted dev_addr=62:ef:11:22:11:22 host_addr=ea:c9:35:d4:66:87 use_eem=0 ; echo -n 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role;;
 2)
    prepare_to_switch ; modprobe g_mass_storage file=$MassStorage1 stall=0 ; echo -n 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role;;
 3)
    prepare_to_switch ; modprobe g_mass_storage file=$MassStorage2 stall=0 ; echo -n 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role;;

esac
}
DIALOG=${DIALOG=dialog}
tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
$DIALOG --clear --title "OTG" \
        --menu "Choice OTG mode:" 12 50 10 \
        "0"  "Disable OTG" \
	"1"  "Usb Ethernet" \
        "2"  "Mass storage device 1" \
        "3"  "Mass storage device 2" 2> $tempfile

retval=$?
choice=`cat $tempfile`
case $retval in
  0)
    apply_choise;;
  1)
    echo "Exit.";;
  255)
    echo "Escape.";;
esac
