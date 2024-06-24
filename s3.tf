resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-${random_id.bucket_id.hex}" # Ensure the bucket name is unique globally

  tags = {
    Name = "example-bucket"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

