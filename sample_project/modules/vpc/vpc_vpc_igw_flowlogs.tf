

####################################################
# VPC
####################################################
resource "aws_vpc" "this" {
  #checkov:skip=CKV2_AWS_12:restricted by aws_default_security_group.default.
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = var.vpcname
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
}

####################################################
# DHCP Optoin set
####################################################
resource "aws_vpc_dhcp_options" "this" {

  domain_name_servers = var.dhcp_options_domain_name_servers
  ntp_servers         = var.dhcp_options_ntp_servers

  tags = {
    Name = "${var.vpcname}-dhcpoptionset"
  }
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

####################################################
# IGW
####################################################
resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpcname}-igw"
  }
}

####################################################
# VPC Flow logs
####################################################
resource "aws_flow_log" "this" {
  log_destination      = var.vpcflowlogsbucket
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  tags = {
    Name = "${var.vpcname}-vpc-flow-logs"
  }
}
