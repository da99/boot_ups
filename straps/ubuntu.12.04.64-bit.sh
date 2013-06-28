# -*- bash -*-
#
set -u -e -o pipefail

# =========== Update/Upgrade =========================
sudo apt-get update

# http://www.cgurnik.com/2011/02/20/fixing-perl-warning-setting-locale-failed-in-ubuntu/
sudo dpkg-reconfigure locales

sudo apt-get upgrade
sudo apt-get dist-upgrade

# =========== Common Programs =========================
sudo apt-get install build-essential libssl-dev python-software-properties python g++ make
sudo apt-get install software-properties-common
sudo apt-get install git curl htop atop


# =========== Optional: Removed apache2 ===============
sudo apt-get remove apache2*
sudo apt-get purge apache2*
sudo apt-get autoremove


# =========== Optional: Install node.js ===============
sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install nodejs

