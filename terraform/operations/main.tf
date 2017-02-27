provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region = "${var.aws_region}"
}

variable "app_name" {
  description = "The name of the application"
  default = "minecraft"
}

resource "aws_vpc" "minecraft" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "minecraft" {
  vpc_id = "${aws_vpc.minecraft.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.minecraft.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.minecraft.id}"
}

resource "aws_subnet" "minecraft" {
  vpc_id                  = "${aws_vpc.minecraft.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Our default security group to access
# the instances over SSH and MC's default port
resource "aws_security_group" "minecraft" {
  name        = "minecraft_security_group"
  vpc_id      = "${aws_vpc.minecraft.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Minecraft access from anywhere
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "minecraft" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ec2-user"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.minecraft.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.minecraft.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.minecraft.id}"

  provisioner "local-exec" {
    command = "./bin/deploy.sh provision"
  }

  tags {
    Name = "mcserver"
  }
}
