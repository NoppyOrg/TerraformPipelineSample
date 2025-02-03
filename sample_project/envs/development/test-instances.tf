/*

####################################################
# IAM role
####################################################
resource "aws_iam_instance_profile" "ec2_instance_role" {
  name = "ec2_instance_role"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

####################################################
# EC2 instances
####################################################
data "aws_ami" "amz2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["amazon"]
}


resource "aws_instance" "test-instance" {

  for_each = {
    instance1 = module.vpc-3az.privatesub1.id
    instance2 = module.vpc-3az.privatesub2.id
    instance3 = module.vpc-3az.privatesub3.id
  }

  ami                    = data.aws_ami.amz2.image_id
  vpc_security_group_ids = [module.vpc-3az.sg-ec2-sg.id]
  key_name               = "CHANGE_KEY_PAIR_NAME"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_role.name
  subnet_id              = each.value

  tags = {
    Name = each.key
  }
}


*/
