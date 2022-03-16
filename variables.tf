variable "region" {
  type = string
}

variable "ec2_type" {
  type = map(any)
  default = {
    default = "t3.small"
    prod    = "t3.micro"
  }
}