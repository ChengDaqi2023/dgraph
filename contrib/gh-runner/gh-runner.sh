#!/bin/bash
# Machine Setup
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    build-essential #Libc Packages
# Docker Setup
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
 echo \
   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo apt-get -y install docker-compose
#Add Docker to sudoers group
sudo usermod -aG docker ${USER}
newgrp docker &
# Install & Setup GH Actions Runner
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.296.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.296.2/actions-runner-linux-x64-2.296.2.tar.gz
echo "34a8f34956cdacd2156d4c658cce8dd54c5aef316a16bbbc95eb3ca4fd76429a  actions-runner-linux-x64-2.296.2.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-linux-x64-2.296.2.tar.gz
./config.sh --url https://github.com/dgraph-io/dgraph --token $TOKEN
# CI Permission Issue
sudo touch /etc/cron.d/ci_permissions_resetter
sudo chown $USER:$USER /etc/cron.d/ci_permissions_resetter
sudo echo "* * * * * root for i in {1..59}; do chown -R $USER:$USER /home/ubuntu/actions-runner/_work & sleep 1; done" >  /etc/cron.d/ci_permissions_resetter 
sudo chown root:root /etc/cron.d/ci_permissions_resetter 
# Start GH Actions
sudo ./svc.sh install
sudo ./svc.sh start
# Reboot Machine
sudo reboot