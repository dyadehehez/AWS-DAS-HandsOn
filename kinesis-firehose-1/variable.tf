#Accesskey of the user, [accesskey, secretkey]
variable "iam_access_key" {
  type    = list(any)
  default = ["<access_key>", "<secret_key>"]
}

#Name of s3 to be created and referenced
variable "my_s3_bucket_name" {
  type    = string
  default = "<bucket_name>"
}

#EC2 config [0 - NAME ,1 - AMI, 2 - INSTANCE TYPE]
variable "ec2_config" {
  type    = list(any)
  default = ["KinesisInstance", "ami-0126086c4e272d3c9", "t2.micro"]
}

#Key name, the created key name
variable "my_ec2_key" {
  type    = string
  default = "Bidata"
}