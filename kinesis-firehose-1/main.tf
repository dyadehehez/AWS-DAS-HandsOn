provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.iam_access_key[0]
  secret_key = var.iam_access_key[1]
}

#provider "tls" {}

#S3
resource "aws_s3_bucket" "orderlogs_s3" {
  bucket = var.my_s3_bucket_name
}

#ARN ROLE POLICY
data "aws_iam_policy_document" "firehose_inline_policy" {
  statement {
    actions   = ["firehose:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "firehose.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )
  inline_policy {
    name   = "policy-for-firehose"
    policy = data.aws_iam_policy_document.firehose_inline_policy.json
  }
}

resource "aws_iam_role_policy_attachment" "test-attach-firehose" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}



#FIREHOSE
resource "aws_kinesis_firehose_delivery_stream" "orderlogs_stream" {
  name        = "PurchaseLogs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = resource.aws_iam_role.firehose_role.arn
    bucket_arn         = resource.aws_s3_bucket.orderlogs_s3.arn
    buffering_interval = "60"
  }
}

#EC2 POLICY AND INSTANCE

data "aws_iam_policy_document" "ec2_inline_policy" {
  statement {
    actions   = ["ec2:*"]
    resources = ["*"]
  }
}
resource "aws_iam_role" "demo-role" {
  name        = "ec2-admin"
  description = "Admin Access Policy for EC2"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
  inline_policy {
    name   = "policy-for-ec2"
    policy = data.aws_iam_policy_document.ec2_inline_policy.json
  }
}

resource "aws_iam_role_policy_attachment" "test-attach-ec2" {
  role       = aws_iam_role.demo-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}



resource "aws_iam_instance_profile" "demo-profile" {
  name = "demo_profile"
  role = aws_iam_role.demo-role.name
}

resource "aws_instance" "ec2_instance" {
  ami                  = var.ec2_config[1]
  instance_type        = var.ec2_config[2]
  key_name             = var.my_ec2_key
  iam_instance_profile = aws_iam_instance_profile.demo-profile.name
  tags = {
    Name = var.ec2_config[0]
  }
}



/*KEYPAIR
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "deployer" {
  key_name   = "BigData"
  public_key = tls_private_key.key.public_key_openssh
}

*/
