####################################################
# VPCE(Interface type)
####################################################
/*
resource "aws_vpc_endpoint" "logs" {
  service_name        = "com.amazonaws.${local.region}.logs"
  vpc_id              = aws_vpc.this.id
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoint_interface.id]
  subnet_ids = (var.availability_zone == "3az" ?
    [
      aws_subnet.privatesub1.id,
      aws_subnet.privatesub2.id,
      aws_subnet.privatesub3[0].id
    ] :
    [
      aws_subnet.privatesub1.id,
      aws_subnet.privatesub2.id
    ]
  )
  tags = {
    Name = "${var.vpcname}-logs"
  }
}
*/



####################################################
# VPCE(S3/Gateway type)
####################################################
resource "aws_vpc_endpoint" "s3" {
  service_name = "com.amazonaws.${local.region}.s3"
  vpc_id       = aws_vpc.this.id
  tags = {
    Name = "${var.vpcname}-s3gw"
  }
}

# associate route tables
resource "aws_vpc_endpoint_route_table_association" "s3_private1" {
  route_table_id  = aws_route_table.private1.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_private2" {
  route_table_id  = aws_route_table.private2.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_private3" {
  count = var.availability_zone == "3az" ? 1 : 0

  route_table_id  = aws_route_table.private3[0].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

####################################################
# VPCE(DynamoDB/Gateway type)
####################################################
resource "aws_vpc_endpoint" "dynamodb" {
  service_name = "com.amazonaws.${local.region}.dynamodb"
  vpc_id       = aws_vpc.this.id
  tags = {
    Name = "${var.vpcname}-dynamodb"
  }
}

# associate route tables
resource "aws_vpc_endpoint_route_table_association" "dynamodb_private1" {
  route_table_id  = aws_route_table.private1.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_private2" {
  route_table_id  = aws_route_table.private2.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_private3" {
  count = var.availability_zone == "3az" ? 1 : 0

  route_table_id  = aws_route_table.private3[0].id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}
