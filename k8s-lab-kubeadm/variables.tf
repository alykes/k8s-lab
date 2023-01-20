variable "region" {
  type = string
  default = "ap-southeast-2"
}

variable "ec2_type" {
  type = map(any)
  default = {
    default = "t3a.small"
    prod    = "t3a.nano"
  }
}