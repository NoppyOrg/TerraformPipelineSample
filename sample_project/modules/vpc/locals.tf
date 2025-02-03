locals {
  pubsub_newbits     = var.availability_zone == "3az" ? 4 : 3
  pubsub_netnum_base = var.availability_zone == "3az" ? 12 : 4

  # set region for VPCE
  region = data.aws_availability_zone.AZs[var.az_id[0]].group_name
}
