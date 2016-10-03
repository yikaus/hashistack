#!/bin/bash -v

wget https://raw.githubusercontent.com/yikaus/hashistack/master/userdata/server.sh
sed -i "s/AWS_REGION/${region}/g" server.sh
sed -i "s/SERVER_DOMAIN/${domain}/g" server.sh
bash server.sh