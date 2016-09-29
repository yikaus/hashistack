#!/bin/bash -v

apt-get update
apt-get install -qq curl unzip

#enable nomad
mkdir -p /var/lib/nomad
wget https://releases.hashicorp.com/nomad/0.4.1/nomad_0.4.1_linux_amd64.zip
unzip nomad_0.4.1_linux_amd64.zip -d /usr/local/bin
rm nomad_0.4.1_linux_amd64.zip

private_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)


cat <<EOF > /etc/nomad
region = "${region}"
datacenter = "dc1"
bind_addr = "$private_ip"
log_level = "INFO"
data_dir = "/var/lib/nomad"
client {
	enabled = true
	servers = [s1.${domain},s2.${domain},s3.${domain}]
	options {
        "driver.raw_exec.enable" = "1"
  }
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

#Fix memory.limit_in_bytes issue on debian8
#https://github.com/hashicorp/nomad/issues/1664
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"quiet cgroup_enable=memory swapaccount=1\"" >> /etc/default/grub
update-grub
reboot
