# --- root/backend.tf ---

terraform {
  backend "s3" {
    bucket = "demodars2"
    key    = "remote.tfstate"
    region = "us-east-1"
  }
}
