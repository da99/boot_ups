#!/usr/bin/env bash 
# Made for: Ubuntu 11.10 (desktop or server)
#
# Useful only for learning Chef-Solo.  Later on you might want
# to use Knife to bootstrap your machines with RBENV and Chef.
#
# One way to run this script: 
# 
#    wget -O boot.sh URL_OF_RAW_FILE && cat boot.sh | bash
#
# Installs RBENV/Ruby and Chef-Solo to local user.
# From then on, you can use Chef-Solo to replace the Ruby installation with something 
# else.
# 
# Based on: 
# https://raw.github.com/hedgehog/rbenv-installer/sysinstall/bin/rbenv-bootstrap-chef-solo
# 
# Alternative:
# https://github.com/sstephenson/rbenv/wiki/Using-rbenv-in-production#wiki-method2
#

# ==== Newbie tip: Use set
# ==== More info: 
# ==== http://www.davidpashley.com/articles/writing-robust-shell-scripts.html
# ==== help set (instead of "man set")
set -u -e

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev libsqlite3-dev 
sudo apt-get -y install git curl htop atop

# ==== rbenv setup  
if [ ! -d $HOME/.rbenv ]; then
  git clone git://github.com/sstephenson/rbenv.git $HOME/.rbenv
  git clone git://github.com/sstephenson/rbenv-vars.git $HOME/.rbenv/plugins/rbenv-vars
fi 

cd $HOME/.rbenv
git pull

cd plugins/rbenv-vars
git pull

if [[ ! `cat ~/.bashrc` =~ "rbenv" ]]; then

  NEW_TEXT=$( cat <<EOF
  export RBENV_ROOT=\$HOME/.rbenv
  export PATH="\$RBENV_ROOT/bin:\$PATH"
  eval "\$(rbenv init -)"
EOF
)

  echo "$NEW_TEXT" >> $HOME/.bashrc
  eval "$NEW_TEXT"

fi

  
if [ ! -d /usr/local/ruby-build ]; then
# Install ruby-build:
pushd $(mktemp -d /tmp/ruby-build.XXXXXXXXXX)
  git clone git://github.com/sstephenson/ruby-build.git
  cd ruby-build
  sudo ./install.sh
popd
fi

# Install Ruby 1.9.3
rbenv install 1.9.3-p125
rbenv local   1.9.3-p125
rbenv global  1.9.3-p125

# Rehash:
rbenv rehash

gem update --system --no-rdoc --no-ri
gem update --no-rdoc --no-ri

gem install bundler --no-rdoc --no-ri --verbose 
gem install rbenv-rehash --no-rdoc --no-ri --verbose
gem install ohai --no-rdoc --no-ri --verbose
gem install chef --no-rdoc --no-ri --verbose 

echo " **** Newbie tip: Reload your login shell: exec \$SHELL -l "
exit 0




