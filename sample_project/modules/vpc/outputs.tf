#--a vpc
output "vpc" {
  value = aws_vpc.this
}

#--subnets
output "publicsub1" {
  value = aws_subnet.publicsub1
}

output "publicsub2" {
  value = aws_subnet.publicsub2
}

output "publicsub3" {
  value = element(concat(aws_subnet.publicsub3.*, tolist([""])), 0)
}

output "privatesub1" {
  value = aws_subnet.privatesub1
}

output "privatesub2" {
  value = aws_subnet.privatesub2
}

output "privatesub3" {
  value = element(concat(aws_subnet.privatesub3.*, tolist([""])), 0)
}

#--route tables
output "public-rtb" {
  value = aws_route_table.public
}

output "private1-rtb" {
  value = aws_route_table.private1
}

output "private2-rtb" {
  value = aws_route_table.private2
}

output "private3-rtb" {
  value = element(concat(aws_route_table.private3.*, tolist([""])), 0)
}

#--Security groups
output "sg-vpce-sg" {
  value = aws_security_group.vpc_endpoint_interface
}

output "sg-ec2-sg" {
  value = aws_security_group.ec2
}