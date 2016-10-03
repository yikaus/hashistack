#!/bin/bash -v

wget https://raw.githubusercontent.com/yikaus/hashistack/master/userdata/client.sh
sed -i "s/AWS_REGION/${region}/g" client.sh
sed -i "s/SERVER_DOMAIN/${domain}/g" client.sh
bash client.sh