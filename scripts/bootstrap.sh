#!/bin/bash

# Have I run before?
if [ $(cat /etc/group | grep nogroup) ]; then
  echo "Installing docker"
  /vagrant/scripts/bootstrap2.sh
  echo "Installing compile tools"
  /vagrant/scripts/install_compile_tools.sh
  echo "Bootstrap complete."
else
  echo "First run. Need to configure couple of prerequisites first."
  /vagrant/scripts/bootstrap1.sh
  echo "------------------------------------------"
  echo "Please issue    vagrant reload --provision"
  echo "------------------------------------------"
fi
