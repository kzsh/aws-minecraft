variable "aws_access_key_id" {
  description = "The AWS access key."
}

variable "aws_secret_access_key" {
  description = "The AWS secret key."
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

variable "key_name" {}

variable "public_key_path" {}

variable "aws_amis" {
  default = {
    us-west-2 = "ami-1e299d7e"
  }
}
