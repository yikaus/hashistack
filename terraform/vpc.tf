
provider "aws" {
  region = "${var.aws_region}"
}

#VPC
resource "aws_vpc" "hashivpc" {
    cidr_block = "${var.vpc_cidr_block}"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
        Name = "hashivpc"
	}
}

##Subnet on each zone
resource "aws_subnet" "server-subnet" {
    vpc_id            = "${aws_vpc.hashivpc.id}"
    count             = "${length(split(",", var.availability_zones))}"
    cidr_block        = "${cidrsubnet(var.vpc_cidr_block, 12, count.index)}"
    availability_zone = "${element(split(",", var.availability_zones), count.index)}"
    map_public_ip_on_launch = true

    tags {
        "Name" = "server-${element(split(",", var.availability_zones), count.index)}-sn"
    }
}

resource "aws_subnet" "client-subnet" {
    vpc_id            = "${aws_vpc.hashivpc.id}"
    count             = "${length(split(",", var.availability_zones))}"
    cidr_block        = "${cidrsubnet(var.vpc_cidr_block, 8, count.index+1)}"
    availability_zone = "${element(split(",", var.availability_zones), count.index)}"
    map_public_ip_on_launch = true

    tags {
        "Name" = "client-${element(split(",", var.availability_zones), count.index)}-sn"
    }
}


#Gateway
resource "aws_internet_gateway" "my_igw" {
    vpc_id = "${aws_vpc.hashivpc.id}"
}

#RouteTable
resource "aws_route_table" "ext_route" {
    vpc_id = "${aws_vpc.hashivpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.my_igw.id}"
    }
    tags {
        Name = "ext_route"
	  }  
}

resource "aws_route_table_association" "client_ra" {
    count = "${length(split(",", var.availability_zones))}"
    subnet_id = "${element(aws_subnet.client-subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.ext_route.id}"
}

resource "aws_route_table_association" "server_ra" {
    count = "${length(split(",", var.availability_zones))}"
    subnet_id = "${element(aws_subnet.server-subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.ext_route.id}"
}

resource "aws_security_group" "hashi_sg" {
  name = "hashi_sg"
  description = "Used in the terraform"
  vpc_id = "${aws_vpc.hashivpc.id}"
  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 2000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }
  
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}