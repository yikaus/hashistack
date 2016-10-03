resource "aws_elb" "server-elb" {
  name = "server-elb"

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
    target              = "HTTP:8500/"
    interval            = 30
  }
}