variable "region" {
  type = string
}

variable "ec2_type" {
  type = map(any)
  default = {
    default = "t3a.small"
    prod    = "t3a.nano"
  }
}