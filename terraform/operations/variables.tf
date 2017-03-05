variable "aws_profile" {
  description = "An aws profile"
  default = "default"
}

variable "aws_region" {
  description = "The AWS region to create resources in."
  default = "us-west-2"
}

variable "availability_zones" {
  description = "The availability zone"
  default = "us-west-2b"
}

variable "vpc_subnet_availability_zone" {
  description = "The VPC subnet availability zone"
  default = "us-west-2b"
}

variable "public_key_path" {}

variable "aws_amis" {
  default = {
    us-west-2 = "ami-1e299d7e"
  }
}
