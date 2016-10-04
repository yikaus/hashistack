resource "aws_elb" "server-elb" {
  name = "server-elb"
  subnets = ["${aws_subnet.server-subnet.*.id}"]
  security_groups = ["${aws_security_group.hashi_sg.id}"]
# consul port
  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }

# nomad port
  listener {
    instance_port     = 4646
    instance_protocol = "http"
    lb_port           = 4646
    lb_protocol       = "http"
  }
# vault port
  listener {
    instance_port     = 8200
    instance_protocol = "http"
    lb_port           = 8200
    lb_protocol       = "http"
  }
    
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8500"
    interval            = 30
  }
}

resource "aws_lb_cookie_stickiness_policy" "lb_consul_sticky" {
      name = "lbConsulSticky"
      load_balancer = "${aws_elb.server-elb.id}"
      lb_port = 8500
      cookie_expiration_period = 600
}

resource "aws_lb_cookie_stickiness_policy" "lb_nomad_sticky" {
      name = "lbNomadSticky"
      load_balancer = "${aws_elb.server-elb.id}"
      lb_port = 4646
      cookie_expiration_period = 600
}

resource "aws_lb_cookie_stickiness_policy" "lb_vault_sticky" {
      name = "lbVaultSticky"
      load_balancer = "${aws_elb.server-elb.id}"
      lb_port = 8200
      cookie_expiration_period = 600
}

output "CONSUL_UI_ADDR"{
  value = "http://${aws_elb.server-elb.dns_name}:8500/ui"
}

output "NOMAD_ADDR"{
  value = "http://${aws_elb.server-elb.dns_name}:4646"
}

output "VAULT_ADDR"{
  value = "http://${aws_elb.server-elb.dns_name}:8200"
}