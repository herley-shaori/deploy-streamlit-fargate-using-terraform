resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

resource "local_file" "bucket_name" {
  content  = aws_s3_bucket.my_bucket.bucket
  filename = "${path.module}/bucket_name.txt"
}