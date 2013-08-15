BOOT_UPS
========

Various files to help bootstrap. THis is higly customized
for my needs so it's highly unlikely that anyone else will
find this useful.


Usage
=====


``` sh

# cd into the dir where you want to install stuff
mkdir -p /apps
sudo chown -R some_user:some_uer /apps
cd /apps
git clone http://github.com/da99/boot_ups.git

cd boot_ups
bin/install_luajit_2_0

# do other magical stuff

```
