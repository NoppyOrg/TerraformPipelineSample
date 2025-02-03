
data "aws_availability_zone" "AZs" {

  for_each = toset(var.az_id)

  zone_id = each.key
}