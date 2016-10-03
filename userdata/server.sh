#!/bin/bash -v

apt-get update
apt-get install -qq curl unzip

# Nomad
mkdir -p /var/lib/nomad
wget https://releases.hashicorp.com/nomad/0.4.1/nomad_0.4.1_linux_amd64.zip
unzip nomad_0.4.1_linux_amd64.zip -d /usr/local/bin
rm nomad_0.4.1_linux_amd64.zip

private_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOF > /etc/nomad
region = "AWS_REGION"
datacenter = "dc1"
bind_addr = "$private_ip"
log_level = "INFO"
data_dir = "/var/lib/nomad"
server {
    enabled = true
    bootstrap_expect = 3
    retry_join = ["s1.SERVER_DOMAIN","s2.SERVER_DOMAIN","s3.SERVER_DOMAIN"]
}
EOF

cat <<EOF > /lib/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
[Service]
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

systemctl enable nomad
systemctl start nomad

# Consul
mkdir -p /var/lib/consul
wget https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip
unzip consul_0.6.4_linux_amd64.zip -d /usr/local/bin
rm consul_0.6.4_linux_amd64.zip

cat <<EOF > /etc/consul
{
  "data_dir": "/var/lib/consul",
  "log_level": "DEBUG",
  "server": true,
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "bootstrap_expect": 3,
  "retry_join": ["s1.SERVER_DOMAIN","s2.SERVER_DOMAIN","s3.SERVER_DOMAIN"]
}
EOF

cat <<EOF > /lib/systemd/system/consul.service
[Unit]
Description=consul
Documentation=https://consul.io/docs/
[Service]
ExecStart=/usr/local/bin/consul agent -config-file /etc/consul -ui
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

systemctl enable consul
systemctl start consul

# Vault
wget https://releases.hashicorp.com/vault/0.6.1/vault_0.6.1_linux_amd64.zip
unzip vault_0.6.1_linux_amd64.zip -d /usr/local/bin
rm vault_0.6.1_linux_amd64.zip

cat <<EOF > /etc/vault
backend "consul" {
  advertise_addr = "http://$private_ip:8200"
  address = "127.0.0.1:8500"
  path = "vault"
}
listener "tcp" {
  address = "$private_ip:8200"
  tls_disable = 1
}
EOF

cat <<EOF > /lib/systemd/system/vault.service
[Unit]
Description=Vault
Documentation=https://vaultproject.io/docs/
[Service]
ExecStart=/usr/local/bin/vault server \
  -config /etc/vault
  
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

systemctl enable vault
systemctl start vault