resource "aws_s3_bucket" "bucket1" {
  bucket = "vimal11102025"  #Use a globally unique name
  force_destroy = true
}