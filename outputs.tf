output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "codepipeline_bucket_name" {
  value = aws_s3_bucket.codepipeline_bucket.bucket
}