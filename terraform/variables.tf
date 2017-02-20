variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-west-2"
}

variable "amis" {
    default = {
      us-west-2 = "ami-7172b611"
    }
}

variable "keypair" {}
