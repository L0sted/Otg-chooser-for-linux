#!/bin/bash
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

function reset_otg {
  echo 0 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role ; modprobe -r {g_mass_storage,g_ether}
}

function apply_choice {
  case $choice in
    0)
      reset_otg;;
    1)
      reset_otg 
      modprobe g_ether iProduct=opi iManufacturer=Losted dev_addr=62:ef:11:22:11:22 host_addr=ea:c9:35:d4:66:87 use_eem=0 && echo 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role
      echo "
allow-hotplug usb0\
iface usb0 inet static\
    address 10.0.0.1\
    netmask 255.255.255.0\
    network 10.0.0.0\
    broadcast 10.0.0.255\
" > /etc/interfaces.otgDemo
      ifup -i /etc/interfaces.otgDemo usb0
      sysctl -w net.ipv4.ip_forward=1
      apt install -y dnsmasq
      echo "interface=usb0\
      dhcp-range=10.0.0.2,10.0.0.255,12h" > /etc/dnsmasq.otgDemo
      echo "Connect otg cable to the PC"
      echo "press Ctrl+C to stop networking"
      trap 'rm /etc/dnsmasq.otgDemo;rm /etc/interfaces.otgDemo;sysctl -w net.ipv4.ip_forward=0; exit 1' 2
      dnsmasq -C /etc/dnsmasq.otgDemo
      ;;
    2)
      reset_otg
      [ -n $HOME/otgDisk.img ] && dd_create
      modprobe g_mass_storage file=$HOME/otgDisk.img
      echo 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role;;
    3)
      reset_otg
      echo "Created /dev/g_printer device"
      ;;
    4)
      reset_otg
      echo "Created /dev/GS0 device"
      ;;
    5)
      reset_otg
      echo "Created /dev/hidgX device(s)"
      ;;
  esac
}

choice=`dialog --clear --title "OTG" \
        --menu "Choice OTG mode:" 12 50 10 \
        "0"  "Disable OTG" \
	      "1"  "Usb Ethernet" \
        "2"  "Storage"  \
        "3"  "Printer" \
        "4"  "Serial" \
        "5"  "Human Input Device" 3>&1 1>&2 2>&3 3>&- ` # some i/o redir magic that i dont understand, just for dialog

retval=$?
case $retval in
  0)
    apply_choice;;
  1)
    echo "Exit.";;
  255)
    echo "Escape.";;
esac
