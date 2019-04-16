variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-northeast-1"
}

# ubuntu-xenial-16.04 LTS (x64 hvm:ebs-ssd)
variable "aws_amis" {
  default = {
    "ap-northeast-1" = "ami-0c70c816092fb1ae3"
    "ap-northeast-2" = "ami-0ac2097c976d173fe"
  }
}
