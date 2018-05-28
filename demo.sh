#!/bin/bash
test=false
if [ `id -u` != 0 ] ; then 
    echo "Need to be root"
    exit 1
fi

function dd_create {
read -p "Lets create an image. Input size in megabytes: " diskSize
echo "Filesystem (vfat or ext4): "
read diskFS
echo creating $diskSize"MB" disk with $diskFS 
dd if=/dev/zero of=$HOME/otgDisk.img bs=1M count=$diskSize
mkfs.$diskFS $HOME/otgDisk.img
}

function prepare_to_switch {
  echo 0 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role ; modprobe -r {g_mass_storage,g_ether}
}

function apply_choise {
  case $choice in
    0)
      prepare_to_switch
      ;;
    1)
      prepare_to_switch 
      modprobe g_ether iProduct=opi iManufacturer=Losted dev_addr=62:ef:11:22:11:22 host_addr=ea:c9:35:d4:66:87 use_eem=0 && echo 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role
      ;;
    2)
      prepare_to_switch 
      [ -n $HOME/otgDisk.img ] && dd_create
      modprobe g_mass_storage file=$HOME/otgDisk.img stall=0 
      echo 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role
      ;;
  esac
}

tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
dialog --clear --title "OTG" \
        --menu "Choice OTG mode:" 12 50 10 \
        "0"  "Disable OTG" \
	      "1"  "Usb Ethernet" \
        "2"  "Storage" 2> $tempfile

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
