

module "vpc-3az" {
  source = "../../modules/vpc"

  vpcname                        = "3azVpc"
  vpc_cidr_block                 = "10.1.3.0/24"
  availability_zone              = "3az" // "2az" or "3az"
  az_id                          = ["apne1-az4", "apne1-az1", "apne1-az2"]
  create_igw                     = true
  create_nagtw                   = true
  sg_ec2_ssh_ingress_source_cidr = "27.0.0.0/8"

  vpcflowlogsbucket = "arn:aws:s3:::nobuyuf-tforg-test01-vpcflowlogs"
}

// 2AZ構成、インターネット接続あり構成例
/* 
module "vpc-2az" {
  source = "../../modules/vpc"

  vpcname                        = "2azVpc"
  vpc_cidr_block                 = "10.1.2.0/24"
  availability_zone              = "2az" // "2az" or "3az"
  create_igw                     = true
  create_nagtw                   = true
  sg_ec2_ssh_ingress_source_cidr = "27.0.0.0/8"

  vpcflowlogsbucket = "arn:aws:s3:::nobuyuf-tforg-test01-vpcflowlogs"
}
*/

// 3AZ構成、インターネット接続なし構成例
/* 
module "private-vpc-3az" {
  source = "../../modules/vpc"

  vpcname           = "private-3azVpc"
  vpc_cidr_block    = "10.99.3.0/24"
  availability_zone = "3az" // "2az" or "3az"
  create_igw        = false
  create_nagtw      = false

  vpcflowlogsbucket = "arn:aws:s3:::nobuyuf-tforg-test01-vpcflowlogs"
}
*/

// 2AZ構成、インターネット接続なし構成例
/* 
module "private-vpc-2az" {
  source = "../../modules/vpc"

  vpcname           = "private-2azVpc"
  vpc_cidr_block    = "10.99.2.0/24"
  availability_zone = "2az" // "2az" or "3az"
  create_igw        = false
  create_nagtw      = false

  vpcflowlogsbucket = "arn:aws:s3:::nobuyuf-tforg-test01-vpcflowlogs"
}
*/
