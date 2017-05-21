#!/bin/bash
yum install -y git wget vim net-tools ipset telnet unzip
groupadd nogroup
echo "Enable OverlayFS"
tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF
echo "Disable SELinux"
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
echo "Done"
