provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route_table" "route_table" {
    vpc_id = "${aws_vpc.default.id}"
    route {
        cidr_block = "10.0.1.0/24"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "main"
    }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "$${route_table}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_key_pair" "deployer" {
  key_name = "minecraft"
  public_key = "${var.keypair}"
}

resource "aws_security_group" "allow_ssh_mc" {
  name = "allow_ssh_mc"
  description = "Allow all ssh and minecraft traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["69.81.195.226/32","173.88.174.148/32", "184.56.60.181/32" ]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.large"
  key_name = "${aws_key_pair.deployer.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_mc.id}"]
  subnet_id = "${aws_subnet.default.id}"
  tags = {
    type = "mcserver"
  }
}
