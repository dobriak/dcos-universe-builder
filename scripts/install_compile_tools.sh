#!/bin/bash
set -ex

RUNAS=vagrant
mkdir /home/${RUNAS}/go
yum install -y epel-release 
yum install -y java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64 python34
wget https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz
tar -C /usr/local/ -zxvf go1.8.linux-amd64.tar.gz 
rm go1.8.linux-amd64.tar.gz
echo "export PATH=\${PATH}:/usr/local/go/bin" >> /home/${RUNAS}/.bashrc
echo "export GOPATH=/home/${RUNAS}/go" >> /home/${RUNAS}/.bashrc

yum groupinstall development -y
yum install -y https://centos7.iuscommunity.org/ius-release.rpm
yum install -y python36u python36u-pip
pushd /usr/bin
  rm -f python3 pip
  ln -s python3.6 python3
  ln -s pip3.6 pip
popd
pip install -U pip wheel jsonschema
pip list
python3 -m ensurepip

sudo -u ${RUNAS} git clone https://github.com/mesosphere/universe.git --branch version-3.x
pushd universe/docker/local-universe/
  sudo make base
popd 
sudo docker images
