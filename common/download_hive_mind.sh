# -*- bash -*-
#
set -u -e -o pipefail -x

if [[ ! -f ~/.ssh/config ]]
then
  wget https://raw.github.com/da99/boot_ups/master/common/ssh_config
  mv ssh_config ~/.ssh/config
fi

git config --global user.name  "$1"
git config --global user.email "$2"

cd /tmp
git clone ssh://$3

