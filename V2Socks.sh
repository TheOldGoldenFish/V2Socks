#!/bin/bash

#### Gathering input ####
DefIP=$(hostname -I | awk '{print $1}')

read -e -p "Please Enter your ip address: " -i "$DefIP" IPAddr
echo $IPAddr

read -e -p "Enter Shadowsocks port: " -i "9000" SSPort
echo $SSPort

stty -echo
read -p "Enter Password: " SSPass
stty echo
echo -e "\n"

read -e -p "Enter nameserver: " -i "8.8.8.8" SSDNS
echo $SSDNS

#### Creating Shadowsocks config ####
echo -n "{
   \"server_port\":$SSPort,
   \"password\":\"$SSPass\"
   \"nameserver\":\"$SSDNS\"," > Shadowsocks.json
echo '
   "server":"192.168.100.20",
   "mode":"tcp_and_udp",
   "timeout":60,
   "method":"chacha20-ietf-poly1305",
   "plugin":"v2ray-plugin_linux_amd64",
   "plugin_opts":"server"
}' >> Shadowsocks.json


#### Downloading V2ray plugin ####
wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz
tar xf v2ray-plugin-linux-amd64-v1.3.2.tar.gz

#### Installing Docker ####
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

#### SystemD settings ####
systemctl start docker
systemctl enable docker

#### Assign Port in the Dockerfile ####
sed "s/SSPort/$SSPort/g" -i Dockerfile

#### Build and run Docker image ####
docker build -t v2socks:local .
docker volume create ssvol
docker network create ssnet --subnet 192.168.100.0/24

docker run -itd --name shadowsocks -v ssvol:/etc/shadowsocks \
--network ssnet --ip 192.168.100.20 -p $SSPort:$SSPort v2socks:local




