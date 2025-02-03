

####################################################
# NAT Gateways
####################################################
#-- Elastic IP for NAT Gateways
resource "aws_eip" "natgw1" {
  count = var.create_igw && var.create_nagtw ? 1 : 0

  vpc = true
  tags = {
    Name = "${var.vpcname}-natgw-${data.aws_availability_zone.AZs[var.az_id[0]].name_suffix}"
  }
}

resource "aws_eip" "natgw2" {
  count = var.create_igw && var.create_nagtw ? 1 : 0

  vpc = true
  tags = {
    Name = "${var.vpcname}-natgw-${data.aws_availability_zone.AZs[var.az_id[1]].name_suffix}"
  }
}

resource "aws_eip" "natgw3" {
  count = var.create_igw && var.create_nagtw && var.availability_zone == "3az" ? 1 : 0

  vpc = true
  tags = {
    Name = "${var.vpcname}-natgw-${data.aws_availability_zone.AZs[var.az_id[2]].name_suffix}"
  }
}

#--  NAT Gateways
resource "aws_nat_gateway" "natgw1" {
  count = var.create_igw && var.create_nagtw ? 1 : 0

  allocation_id = aws_eip.natgw1[0].id
  subnet_id     = aws_subnet.publicsub1.id
  tags = {
    Name = "${var.vpcname}-natgw-${data.aws_availability_zone.AZs[var.az_id[0]].name_suffix}"
  }
}

resource "aws_nat_gateway" "natgw2" {
  count = var.create_igw && var.create_nagtw ? 1 : 0

  allocation_id = aws_eip.natgw2[0].id
  subnet_id     = aws_subnet.publicsub2.id
  tags = {
    Name = "${var.vpcname}-natgw-${data.aws_availability_zone.AZs[var.az_id[1]].name_suffix}"
  }
}

resource "aws_nat_gateway" "natgw3" {
  count = var.create_igw && var.create_nagtw && var.availability_zone == "3az" ? 1 : 0

  allocation_id = aws_eip.natgw3[0].id
  subnet_id     = aws_subnet.publicsub3[0].id
  tags = {
    Name = "${var.vpcname}-natgw-${data.aws_availability_zone.AZs[var.az_id[2]].name_suffix}"
  }
}