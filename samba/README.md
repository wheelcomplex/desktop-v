# Install Samba 4.8 from sources for MacOS HighSierra Time Machine backup on Ubuntu 18.04 x86_64 LTS

From MacOS HighSierra(10.13) Apple use samba for time machine backup, this require '--enable-spotlight' option for samba configure.

Note: run follow commands by no-root user in bash shell.

+ Install required package dependencies:

```
sudo apt-get update && sudo apt-get install build-essential acl attr \
  autoconf bison debhelper dnsutils docbook-xml docbook-xsl flex \
  gdb krb5-user libacl1-dev libaio-dev libattr1-dev libblkid-dev \
  libbsd-dev libcap-dev libcups2-dev libgnutls28-dev libjson-perl \
  libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl \
  libpopt-dev libreadline-dev perl perl-modules pkg-config \
  python-all-dev python-dev cups python-dnspython python-crypto \
  xsltproc zlib1g-dev libsystemd-dev libgpgme11-dev \
  python-m2crypto libtracker-sparql-2.0-0 libtracker-sparql-2.0-dev
```

+ Download Samba sources from github and apply patch for building with libtracker-sparql-2.0:

```
mkdir -p ~/tmp/ && cd ~/tmp && git clone https://github.com/samba-team/samba.git && \
  cd samba && wget -q https://github.com/samba-team/samba/pull/143.patch && \
  patch -p1 < 143.patch
```
  
+ Configure for time machine:

```
./configure \
 --enable-spotlight \
 --with-systemd \
 --prefix=/usr \
 --exec-prefix=/usr \
 --sysconfdir=/etc \
 --libdir=/usr/lib/x86_64-linux-gnu \
 --localstatedir=/var \
 --with-smbpasswd-file=/etc/samba/smbpasswd \
 --enable-fhs

```
Note: replace x86_64 with aarch64 if building for arm64.

+ Build and install:

```
make -j$(grep -c ^processor /proc/cpuinfo) && sudo make -j$(grep -c ^processor /proc/cpuinfo) install
```

+ Prepare the configuration files and CUPS print server SMB spooler support:
Note: make sure the directorys (defined in smb.conf) for very sharing user have been created and have correct permisions.
Otherwise Time machine will return error message: OSStatus -1073741275.

```
sudo touch /etc/samba/lmhosts
sudo touch /etc/samba/smb.conf
sudo touch /etc/samba/smbpasswd

test -f /etc/samba/smb.conf && sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.old

sudo wget -q https://raw.githubusercontent.com/wheelcomplex/desktop-v/master/samba/smb.conf -O /etc/samba/smb.conf

sudo ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb
```

+ Create samba user:

```
sudo smbpasswd -a <system username>
```

+ On boot systemd services:

```
sudo cp -v bin/default/packaging/systemd/*.service /lib/systemd/system/

sudo systemctl start nmb.service
sudo systemctl enable nmb.service
sudo systemctl start smb.service
sudo systemctl enable smb.service
sudo systemctl start winbind.service
sudo systemctl enable winbind.service
```

+ Broadcast samba services to macOS:

```
sudo apt install -y avahi-daemon

sudo wget -q https://raw.githubusercontent.com/wheelcomplex/desktop-v/master/samba/smb.service -O /etc/avahi/services/smb.service

sudo systemctl restart avahi-daemon
```

+ Check status:

```
sudo systemctl status nmb.service
sudo systemctl status smb.service
sudo systemctl status winbind.service
```

+ Debug hints:

Use Bonjour Browser [](http://www.tildesoft.com/) on macOS to make sure the samba service is visible.
Connect the samba share from Finder and create test directory to make sure user/password have setup correctly.

+ Tips:
+ Use [mdns-repeater](https://github.com/wheelcomplex/mdns-repeater) to relay broadcast when the samba server and macOS in difference subnet.

reference:
* [Robert LaRocca: Build Samba 4.6.x with Time Machine support on Ubuntu 16.04](https://laroccx.wordpress.com/2017/06/14/build-samba-4-6-x-with-time-machine-support-on-ubuntu-16-04/)
