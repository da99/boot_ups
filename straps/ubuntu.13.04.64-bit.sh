#!/usr/bin/env bash
# -*- bash -*-
#
#
# This file has to be run in /tmp
# === The perms for $apps_dir will change.
#     Git will report changes to the tree.
#     We do not want that, so we move this
#     dir to a diff place.

# Pass args to this file:
#    this_file NAME_OF_MACHINE /target/dir

set -u -e -o pipefail

NAME_OF_MACHINE="$1"
apps_dir="$2"
FILES="https://raw.github.com/da99/boot_ups/master/common"

temp=/tmp/boot_ups
if [[ "$temp" != "$(pwd)" ]]
then
  echo "!!! Invalid dir. PWD must be: $temp" 1>&2
  exit 1
fi



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

  bin/set_locale

  done_is loc

fi


# =========== Update/Upgrade =========================
if is_not_done upgrade
then

  bin/upgrade

  sudo dpkg-reconfigure tzdata
  sudo dpkg-reconfigure locales
  sudo date

  done_is upgrade
fi


# =========== Common Programs =========================
bin/ubuntu_13_deps


# ===== Setup UFW:
bin/reset_ufw

# =========== Remove apache2 ==========================
sudo apt-get remove apache2*
sudo apt-get purge apache2*



# ========== Remove sendmail ==========================
# from: http://www.bybe.net/blog/removing-sendmail-mta-from-start-up-ubuntu.html
sudo apt-get remove sendmail sendmail-bin postfix
sudo apt-get purge postfix exim4 sendmail sendmail-bin




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


if is_not_done git
then
  git config --global user.name  "$NAME_OF_MACHINE"
  git config --global user.email "spam@$NAME_OF_MACHINE"
  done_is git
fi



# ============== Goodbye ===================================================
sudo apt-get autoremove
echo -e "\n\n"
echo "---> sendmail removed. REBOOT machine. <---"
echo "---> fstab updated.    REBOOT machine. <---"




