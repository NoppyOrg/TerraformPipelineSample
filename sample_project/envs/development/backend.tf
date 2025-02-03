terraform {
  backend "s3" {
    bucket = "github-action-and-terraform-terraformbackendbucket-mwavz4a4k8st"
    key    = "sample_project/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
