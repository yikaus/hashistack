resource "aws_autoscaling_group" "server-asg" {
  name = "server-asg"
  max_size = "3"
  min_size = "3"
  desired_capacity = "3"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.server-lc.name}"
  vpc_zone_identifier = ["${aws_subnet.server-subnet.*.id}"]
  tag {
    key = "Name"
    value = "server-host"
    propagate_at_launch = "true"
  }
  tag {
    key = "DomainMeta"
    value = "${aws_route53_zone.dev.id}:${var.privateDNS}"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "server-lc" {
  name = "server-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.server_instance_type}"
  # Security group
  security_groups = ["${aws_security_group.hashi_sg.id}"]
  user_data = "${data.template_cloudinit_config.serverconfig.rendered}"
  key_name = "${var.key_name}"
}

resource "aws_autoscaling_group" "client-asg" {
  #availability_zones = ["${split(",", var.availability_zones)}"]
  depends_on = ["aws_autoscaling_group.server-asg"]
  name = "client-asg"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.client-lc.name}"
  vpc_zone_identifier = ["${aws_subnet.client-subnet.*.id}"]
  tag {
    key = "Name"
    value = "client-host"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "client-lc" {
  name = "client-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.client_instance_type}"
  # Security group
  security_groups = ["${aws_security_group.hashi_sg.id}"]
  user_data = "${data.template_cloudinit_config.clientconfig.rendered}"
  key_name = "${var.key_name}"
}

