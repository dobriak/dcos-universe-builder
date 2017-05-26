#!/bin/bash
source aws.config

scp -i ${EC2_KEY} scripts/* ${EC2_USER}@${PUBLIC_IP}:
ssh -i ${EC2_KEY} ${EC2_USER}@${PUBLIC_IP} sed -i -e "s/^RUNAS=.*/RUNAS=${EC2_USER}/" /home/${EC2_USER}/bootstrap.sh
ssh -i ${EC2_KEY} ${EC2_USER}@${PUBLIC_IP} "sudo /home/${EC2_USER}/bootstrap.sh"
ssh -i ${EC2_KEY} ${EC2_USER}@${PUBLIC_IP}