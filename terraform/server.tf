
resource "aws_instance" "server" {
  count = "${var.server_size}"
  instance_type = "${var.server_instance_type}"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${var.key_name}"
  private_ip = "${lookup(var.server_ips, count.index)}"
  subnet_id = "${element(aws_subnet.server-subnet.*.id, count.index)}"
  
  vpc_security_group_ids = ["${aws_security_group.hashi_sg.id}"]
  user_data = "${data.template_cloudinit_config.serverconfig.rendered}"
  tags {
    Name = "server-host-${count.index+1}"
  }
}

output "serverIP"{
  value = ["${aws_instance.server.*.public_ip}"]
}