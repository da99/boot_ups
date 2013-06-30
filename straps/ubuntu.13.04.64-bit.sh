# -*- bash -*-
#
set -u -e -o pipefail

# http://www.cgurnik.com/2011/02/20/fixing-perl-warning-setting-locale-failed-in-ubuntu/
sudo dpkg-reconfigure locales


# =========== Update/Upgrade =========================
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade


# =========== Common Programs =========================
sudo apt-get install build-essential            \
                     g++                        \
                     make                       \
                     software-properties-common \
                     tree                       \
                     trash-cli                  \
                     python-software-properties \
                     zlib1g-dev                 \
                     libssl-dev                 \
                     libsqlite3-dev             \
                     libxslt-dev                \
                     libxml2-dev                \
                     libreadline6               \
                     libreadline6-dev           \
                     git                        \
                     curl                       \
                     htop                       \
                     atop


# =========== Remove apache2 ==========================
sudo apt-get remove apache2*
sudo apt-get purge apache2*

# ========== Remove sendmail ==========================
# from: http://www.bybe.net/blog/removing-sendmail-mta-from-start-up-ubuntu.html
sudo apt-get remove sendmail sendmail-bin postfix
sudo apt-get purge postfix exim4 sendmail sendmail-bin

sudo apt-get autoremove

# =========== Install node.js ===============
# =========== Install Nginx   ===============
sudo add-apt-repository ppa:chris-lea/node.js
sudo add-apt-repository  nginx/stable

sudo apt-get update

sudo apt-get install nodejs
sudo apt-get install nginx



# ============== Goodbye ===================================================
echo -e "\n\n ---> sendmail removed. REBOOT this machine manually. <---"
