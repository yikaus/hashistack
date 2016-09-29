resource "aws_route53_zone" "dev" {
  name = "${var.privateDNS}"
  vpc_id = "${aws_vpc.hashivpc.id}"
  force_destroy = true
}