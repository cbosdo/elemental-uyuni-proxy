#!/bin/bash

# Copyright (c) 2018 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

echo "Configure image: [$kiwi_iname]..."

#======================================
# Setup baseproduct link
#--------------------------------------
if [ ! -e /etc/products.d/baseproduct ]; then
    suseSetupProduct
fi

#======================================
# Import repositories' keys
#--------------------------------------
suseImportBuildKey

# Elemental config
echo IMAGE_REPO=\"registry.world-co.com/elemental/5.3\"         >> /etc/os-release
echo IMAGE_TAG=\"1.0\"           >> /etc/os-release
echo IMAGE=\"registry.world-co.com/elemental/5.3:1.0\" >> /etc/os-release
echo TIMESTAMP="`date +'%Y%m%d%H%M%S'`" >> /etc/os-release
echo GRUB_ENTRY_NAME=\"Elemental\" >> /etc/os-release

# Ensure /tmp is mounted as tmpfs by default
if [ -e /usr/share/systemd/tmp.mount ]; then
  cp /usr/share/systemd/tmp.mount /etc/systemd/system;
fi

# Save some space
zypper clean --all
rm -rf /var/log/update*
>/var/log/lastlog
rm -rf /boot/vmlinux*

# Rebuild initrd to setup dracut with the boot configurations
mkinitrd
# aarch64 has an uncompressed kernel so we need to link it to vmlinuz
kernel=$(ls /boot/Image-* | head -n1)
if [ -e "$kernel" ]; then ln -sf "${kernel#/boot/}" /boot/vmlinuz; fi

exit 0
