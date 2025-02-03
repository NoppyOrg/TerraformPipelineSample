terraform {
  backend "s3" {
    bucket = "github-action-and-terraform-terraformbackendbucket-fl9awiim7frn"
    key    = "sample_project/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
