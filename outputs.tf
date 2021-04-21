output "aws_s3_bucket_name" {
  description = "AWS S3 Bucket Name"
  value       = aws_s3_bucket.default[0].id
}

output "aws_s3_bucket_arn" {
  description = "AWS S3 Bucket ARN"
  value       = aws_s3_bucket.default[0].arn
}
