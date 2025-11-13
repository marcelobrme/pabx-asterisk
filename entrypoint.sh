#!/bin/bash
echo "Iniciando Asterisk com chan_dongle..."
modprobe usbserial vendor=0x12d1 product=0x1001
asterisk -f -U root
