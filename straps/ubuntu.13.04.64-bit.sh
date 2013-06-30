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

# =========== Stricter Shared Memory =================
# === IP-spoofing
# === Harden Network with sysctl settings:
# === from: http://cbracco.me/vps/
append_into  ip.spoof.conf /etc/sysctl.conf
sudo sysctl -p

append_into etc.host.conf /etc/host.conf

# === Secure shared memory
append_into  shm.conf /etc/fstab
sudo mount -a



# =========== Localization ===========================
loc_done="loc_done"
if [[ is_done $loc_done ]]
then
  #
  # from: http://ubuntuforums.org/showthread.php?t=1346581
  #
  # http://www.cgurnik.com/2011/02/20/fixing-perl-warning-setting-locale-failed-in-ubuntu/
  sudo dpkg-reconfigure locales
  sudo locale-gen en_US en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8
  touch $loc_done
fi


# =========== Update/Upgrade =========================
upgrade_done="/tmp/upgrade_done"
if [[ ! -f "$upgrade_done" ]]
then
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt-get dist-upgrade
  sudo dpkg-reconfigure tzdata
  sudo dpkg-reconfigure locales
  sudo date


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
                     ufw                        \
                     rkhunter chkrootkit        \
                     git                        \
                     curl                       \
                     htop                       \
                     atop                       \
                     sqlite3


# ===== Check for rootkits with RKHunter and CHKRootKit:
sudo chkrootkit
sudo rkhunter --update
sudo rkhunter --propupd
sudo rkhunter --check



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

git_done="/tmp/git_done"
if [[ ! -f "$git_done" ]]
then
  git config --global user.name  "$NAME_OF_MACHINE"
  git config --global user.email "spam@$NAME_OF_MACHINE"
  touch "$git_done"
fi


if [ ! -d /home/$NEW_USER ]
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




