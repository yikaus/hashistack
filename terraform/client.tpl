#!/bin/bash -v

wget https://raw.githubusercontent.com/yikaus/hashistack/master/userdata/client.sh
sed -i "s/AWS_REGION/${region}/" client.sh
sed -i "s/SERVER_DOMAIN/${domain}/" client.sh
bash client.sh