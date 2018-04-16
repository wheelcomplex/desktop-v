#!/bin/sh
cd `dirname $0`
cd `realpath .`
pwd
make -j12
if [ $? -ne 0 ]
then
	./configure \
	 --enable-spotlight \
	 --with-systemd \
	 --prefix=/usr \
	 --exec-prefix=/usr \
	 --sysconfdir=/etc \
	 --libdir=/usr/lib/x86_64-linux-gnu \
	 --localstatedir=/var \
	 --with-smbpasswd-file=/etc/samba/smbpasswd \
	 --enable-fhs || exit 1
	 make -j12 || exit 1 
 fi
 set -e
sudo make -j8 install
sudo cp -v bin/default/packaging/systemd/*.service /lib/systemd/system/

sudo systemctl stop nmb.service
sudo systemctl stop smb.service
sudo systemctl stop winbind.service

sudo systemctl start nmb.service
sudo systemctl enable nmb.service
sudo systemctl start smb.service
sudo systemctl enable smb.service
sudo systemctl start winbind.service
sudo systemctl enable winbind.service
#
