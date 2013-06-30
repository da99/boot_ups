# -*- bash -*-
#
set -u -e -o pipefail

NEW_USER="deployer"
NAME_OF_MACHINE="$1"
FILES="https://raw.github.com/da99/boot_ups/master/common"

function append_into {
  name="$1"
  target="$2"
  echo -e "\n\n"

  wget -O /tmp/$name $FILES/$name

  part_c="$(cat /tmp/$name)"
  orig_c="$(cat $target)"
  if [[ "$orig_c" == *"$part_c"* ]]
  then
    echo "Already setup: $name -> $target"
  else
    echo "$part_c" >> "$target"
    echo -e "\nInserted: $name -> $target"
  fi
}

function done_is {
  touch "/tmp/$1"
}

function is_not_done {
  [[ ! -f "/tmp/$1" ]]
}

# =========== Stricter Shared Memory =================
# === IP-spoofing
# === Harden Network with sysctl settings:
# === from: http://cbracco.me/vps/
append_into  sysctl.conf /etc/sysctl.conf
sudo sysctl -p

append_into etc.host.conf /etc/host.conf

# === Secure shared memory
append_into  shm.conf /etc/fstab
sudo mount -a



# =========== Localization ===========================
if is_not_done loc
then
  #
  # from: http://ubuntuforums.org/showthread.php?t=1346581
  #
  # http://www.cgurnik.com/2011/02/20/fixing-perl-warning-setting-locale-failed-in-ubuntu/
  sudo dpkg-reconfigure locales
  sudo locale-gen en_US en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8

  done_is loc
fi


# =========== Update/Upgrade =========================
if is_not_done upgrade
then
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt-get dist-upgrade
  sudo dpkg-reconfigure tzdata
  sudo dpkg-reconfigure locales
  sudo date

  done_is upgrade
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
                     ufw                        \
                     rkhunter chkrootkit        \
                     git                        \
                     curl                       \
                     htop                       \
                     atop                       \
                     sqlite3



# ===== Setup UFW:
sudo ufw disable
sudo ufw reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw logging on
sudo ufw allow ssh
sudo ufw enable


# =========== Remove apache2 ==========================
sudo apt-get remove apache2*
sudo apt-get purge apache2*



# ========== Remove sendmail ==========================
# from: http://www.bybe.net/blog/removing-sendmail-mta-from-start-up-ubuntu.html
sudo apt-get remove sendmail sendmail-bin postfix
sudo apt-get purge postfix exim4 sendmail sendmail-bin



# =========== Install node.js ===============
# =========== Install Nginx   ===============
if is_not_done dev
then
  sudo add-apt-repository ppa:chris-lea/node.js
  sudo add-apt-repository ppa:nginx/stable

  sudo apt-get update

  sudo apt-get install nodejs
  sudo apt-get install nginx

  done_is dev
fi

# ========== Setup base ssh config for bitbucket and github
if [[ ! -f ~/.ssh/config ]]
then

  mkdir -p ~/.ssh
  chmod 0700 ~/.ssh
  wget https://raw.github.com/da99/boot_ups/master/common/ssh_config
  mv ssh_config ~/.ssh/config

  # === clear known_hosts and put known
  ssh-keyscan -t rsa bitbucket.org >  ~/.ssh/known_hosts
  ssh-keyscan -t rsa github.com    >> ~/.ssh/known_hosts

  chmod 0440 -R ~/.ssh
fi

# ==== Get user input:
# ==== From: http://stackoverflow.com/questions/226703/how-do-i-prompt-for-input-in-a-linux-shell-script

if is_not_done git
then
  git config --global user.name  "$NAME_OF_MACHINE"
  git config --global user.email "spam@$NAME_OF_MACHINE"
  done_is git
fi


if [[ ! -d /home/$NEW_USER ]]
then
  #
  # Delete user:
  # http://manpages.ubuntu.com/manpages/hardy/man8/deluser.8.html
  #
  # Create home dir manually:
  # http://forums.fedoraforum.org/showthread.php?t=97089
  #
  useradd -d /home/$NEW_USER -m -s $(which bash) --skel /etc/skel $NEW_USER

  # ==== Save name of machine
  echo "$NAME_OF_MACHINE" > /home/$NEW_USER/NAME_OF_MACHINE
  chown $NEW_USER:$NEW_USER /home/$NEW_USER/NAME_OF_MACHINE
fi

if [[ ! -d /apps ]]
then

  mkdir -p /apps/tmp
  mkdir /apps/logs
  mkdir /apps/pids
  mkdir /apps/backup
fi

chmod 0755 -R /apps
chown $NEW_USER:$NEW_USER -R /apps


# ============== Goodbye ===================================================
sudo apt-get autoremove
echo -e "\n\n"
echo "---> sendmail removed. REBOOT machine. <---"
echo "---> fstab updated.    REBOOT machine. <---"




