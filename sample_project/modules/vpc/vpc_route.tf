####################################################
# Route Tables
####################################################

# public route ------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpcname}-public"
  }
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_igw ? 1 : 0

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}


# private route ------------------------
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpcname}-privatesub-${data.aws_availability_zone.AZs[var.az_id[0]].name_suffix}"
  }
}

resource "aws_route" "privatesub1-natgwroute" {
  count = var.create_igw && var.create_nagtw ? 1 : 0

  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw1[0].id
}

#---
resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpcname}-privatesub-${data.aws_availability_zone.AZs[var.az_id[1]].name_suffix}"
  }
}

resource "aws_route" "privatesub2-natgwroute" {
  count = var.create_igw && var.create_nagtw ? 1 : 0

  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw2[0].id
}

#---
resource "aws_route_table" "private3" {
  count = var.availability_zone == "3az" ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpcname}-privatesub-${data.aws_availability_zone.AZs[var.az_id[2]].name_suffix}"
  }
}

resource "aws_route" "privatesub3-natgwroute" {
  count = var.create_igw && var.create_nagtw && var.availability_zone == "3az" ? 1 : 0

  route_table_id         = aws_route_table.private3[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw3[0].id
}

####################################################
# Associate route tables to subnets
####################################################
# Public Subnets ----
resource "aws_route_table_association" "public_to_pubsub1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.publicsub1.id
}

resource "aws_route_table_association" "public_to_pubsub2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.publicsub2.id
}

resource "aws_route_table_association" "public_to_pubsub3" {
  count = var.availability_zone == "3az" ? 1 : 0

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.publicsub3[0].id
}
# Private Subnets ----
resource "aws_route_table_association" "private-tbl1_to_privatesub1" {
  route_table_id = aws_route_table.private1.id
  subnet_id      = aws_subnet.privatesub1.id
}

resource "aws_route_table_association" "private-tbl2_to_privatesub2" {
  route_table_id = aws_route_table.private2.id
  subnet_id      = aws_subnet.privatesub2.id
}

resource "aws_route_table_association" "private-tbl3_to_privatesub3" {
  count = var.availability_zone == "3az" ? 1 : 0

  route_table_id = aws_route_table.private3[0].id
  subnet_id      = aws_subnet.privatesub3[0].id
}