
output "kms_key_arn" {
  value = data.aws_kms_key.dynamodb-key.arn
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

# Output the table name
output "dynamodb_table_name" {
  value = aws_dynamodb_table.MPG_table.name
}

output "local_secondary_index" {
  value = aws_dynamodb_table.MPG_table.local_secondary_index
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.MPG_table.arn
}