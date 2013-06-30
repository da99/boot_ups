# -*- bash -*-
#
set -u -e -o pipefail

# http://www.cgurnik.com/2011/02/20/fixing-perl-warning-setting-locale-failed-in-ubuntu/
sudo dpkg-reconfigure locales


# =========== Update/Upgrade =========================
upgrade_done="/tmp/upgrade_done"
if [[ ! -f "$upgrade_done" ]]
then
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt-get dist-upgrade
  touch "$upgrade_done"
fi

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
dev_done="/tmp/dev_done"
if [[ ! -f "$dev_done" ]]
then
  sudo add-apt-repository ppa:chris-lea/node.js
  sudo add-apt-repository  nginx/stable

  sudo apt-get update

  sudo apt-get install nodejs
  sudo apt-get install nginx
  touch "$dev_done"
fi

# ========== Setup base ssh config for bitbucket and github
if [[ ! -f ~/.ssh/config ]]
then
  wget https://raw.github.com/da99/boot_ups/master/common/ssh_config
  mk -p ~/.ssh
  mv ssh_config ~/.ssh/config
fi

# ==== Get user input:
# ==== From: http://stackoverflow.com/questions/226703/how-do-i-prompt-for-input-in-a-linux-shell-script

git_done="/tmp/git_done"
if [[ ! -f "$git_done" ]]
then
  echo "What is the git user name?"
  read NAME
  git config --global user.name  "$NAME"

  echo "What is the git user email?"
  read EMAIL
  git config --global user.email "$EMAIL"
  touch "$git_done"
fi


if [[ ! -d /apps ]]
then
  echo "What git repo to download to /apps? ssh://[ path ]"
  read URL
  mkdir -p /apps
  cd /apps
  git clone ssh://$URL
fi


# ============== Goodbye ===================================================
echo -e "\n\n ---> sendmail removed. REBOOT this machine manually. <---"




