# Data source for existing IAM Role
data "aws_iam_role" "ec2_role" {
  name = "ec2_instance_role"
}

# Data source for existing IAM Instance Profile
data "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_role"  
}

# resource "aws_iam_role" "ec2_role" {
#   name = "ec2_instance_role"

#   assume_role_policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [{
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }]
#   })
# }

# resource "aws_iam_policy" "s3_access_policy" {
#   name        = "s3_access_policy"
#   description = "Policy for EC2 instances to access S3 artifacts bucket"

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [{
#       "Effect": "Allow",
#       "Action": [
#         "s3:GetObject"
#       ],
#       "Resource": [
#         "arn:aws:s3:::${var.artifacts_bucket_name}/*"
#       ]
#     }]
#   })
# }

# # Attach Policy to Role
# resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = aws_iam_policy.s3_access_policy.arn
# }

# # IAM Instance Profile
# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "ec2_instance_profile"
#   role = aws_iam_role.ec2_role.name
# }
