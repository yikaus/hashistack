#!/bin/bash -v

wget https://raw.githubusercontent.com/yikaus/hashistack/${release}/userdata/server.sh
sed -i "s/AWS_REGION/${region}/g" server.sh
sed -i "s/SERVER_DOMAIN/${domain}/g" server.sh
sed -i "s/NOMAD_VERSION/${nomad_version}/g" server.sh
sed -i "s/VAULT_VERSION/${vault_version}/g" server.sh
sed -i "s/CONSUL_VERSION/${consul_version}/g" server.sh
bash server.sh