#!/usr/bin/env bash
# -*- bash -*-
#
set -u -e -o pipefail

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install htop
sudo apt-get remove apache2*
sudo apt-get purge apache2*
sudo apt-get autoremove

sudo apt-get dist-upgrade

#!/usr/bin/env node
# -*- js   -*-
#
