#!/bin/bash

RUNAS=vagrant

tee /etc/yum.repos.d/docker.repo <<- 'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/override.conf <<- 'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon
EOF
echo "Installing docker"
yum install -y docker-engine-1.12.6
systemctl start docker
systemctl enable docker
docker ps

echo "Installing compile tools"
sudo yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
yum install -y epel-release git dialog net-tools
yum groupinstall development -y
yum install -y https://centos7.iuscommunity.org/ius-release.rpm
yum install -y python36u python36u-pip
pushd /usr/bin
  rm -f python3 pip
  ln -s python3.6 python3
  ln -s pip3.6 pip
popd
pip install -U pip wheel jsonschema
python3 -m ensurepip

sudo -u ${RUNAS} git clone https://github.com/mesosphere/universe.git --branch version-3.x
pushd universe/docker/local-universe/
  sudo make base
popd 
sudo docker images

echo "Bootstrap complete. Run select_frameworks.sh to graphically select frameworks for inclusion in your local universe tarball."