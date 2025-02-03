####################################################
# Subnets( 2az or 3az )
####################################################
resource "aws_subnet" "publicsub1" {
  vpc_id               = aws_vpc.this.id
  cidr_block           = cidrsubnet(var.vpc_cidr_block, local.pubsub_newbits, local.pubsub_netnum_base)
  availability_zone_id = var.az_id[0]
  tags = {
    Name = "${var.vpcname}-${var.public_subnet_name}-${data.aws_availability_zone.AZs[var.az_id[0]].name_suffix}"
  }
}

resource "aws_subnet" "publicsub2" {
  vpc_id               = aws_vpc.this.id
  cidr_block           = cidrsubnet(var.vpc_cidr_block, local.pubsub_newbits, local.pubsub_netnum_base + 1)
  availability_zone_id = var.az_id[1]
  tags = {
    Name = "${var.vpcname}-${var.public_subnet_name}-${data.aws_availability_zone.AZs[var.az_id[1]].name_suffix}"
  }
}

resource "aws_subnet" "publicsub3" {
  count = var.availability_zone == "3az" ? 1 : 0

  vpc_id               = aws_vpc.this.id
  cidr_block           = cidrsubnet(var.vpc_cidr_block, local.pubsub_newbits, local.pubsub_netnum_base + 2)
  availability_zone_id = var.az_id[2]
  tags = {
    Name = "${var.vpcname}-${var.public_subnet_name}-${data.aws_availability_zone.AZs[var.az_id[2]].name_suffix}"
  }
}

resource "aws_subnet" "privatesub1" {
  vpc_id               = aws_vpc.this.id
  cidr_block           = cidrsubnet(var.vpc_cidr_block, 2, 0)
  availability_zone_id = var.az_id[0]
  tags = {
    Name = "${var.vpcname}-${var.private_subnet_name}-${data.aws_availability_zone.AZs[var.az_id[0]].name_suffix}"
  }
}

resource "aws_subnet" "privatesub2" {
  vpc_id               = aws_vpc.this.id
  cidr_block           = cidrsubnet(var.vpc_cidr_block, 2, 1)
  availability_zone_id = var.az_id[1]
  tags = {
    Name = "${var.vpcname}-${var.private_subnet_name}-${data.aws_availability_zone.AZs[var.az_id[1]].name_suffix}"
  }
}

resource "aws_subnet" "privatesub3" {
  count = var.availability_zone == "3az" ? 1 : 0

  vpc_id               = aws_vpc.this.id
  cidr_block           = cidrsubnet(var.vpc_cidr_block, 2, 2)
  availability_zone_id = var.az_id[2]
  tags = {
    Name = "${var.vpcname}-${var.private_subnet_name}-${data.aws_availability_zone.AZs[var.az_id[2]].name_suffix}"
  }
}
