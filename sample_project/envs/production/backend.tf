terraform {
  backend "s3" {
    bucket = "github-action-and-terraform-terraformbackendbucket-kudvowdxk2u6"
    key    = "sample_project/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
