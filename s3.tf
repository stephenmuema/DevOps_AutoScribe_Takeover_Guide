resource "aws_s3_bucket" "data_lake" {
  bucket = "autoscribe-data-lake"
  acl    = "private"

  tags = {
    Name = "data_lake"
  }
}
