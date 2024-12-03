
data "aws_region" "current" { }

data "aws_kms_key" "dynamodb-key" {
  # key_id = "alias/dynamodb-key"
  key_id = var.aws_kms_key
}

resource "aws_dynamodb_table" "MPG_table" {
  #name           = "MPGTable"
  name = var.aws_dynamodb_table
  billing_mode   = "PAY_PER_REQUEST"  # Alternatively, use "PROVISIONED" for provisioned capacity
  # Use if you are using PROVISIONED billing
  # read_capacity  = 5
  # write_capacity = 5
  hash_key       = "Userid"
  range_key      = "Timestamp"
  table_class = "STANDARD_INFREQUENT_ACCESS"  # Or use STANDARD (which is default) the table class
  deletion_protection_enabled = true
  # stream_enabled = true
  # stream_view_type = "NEW_IMAGE"

  attribute {
    name = "Userid"
    type = "S"  # S means string type
  }

  attribute {
    name = "Timestamp"
    type = "N"  # Number type, suitable for sorting by time
  }

 # Local Secondary Index
  local_secondary_index {
    name              = "Location"
    range_key         = "Timestamp"
    projection_type   = "INCLUDE"
    non_key_attributes = ["LocationName"]  # Attributes to be projected into the index
  }

  # Global Secondary Index
  global_secondary_index {
    name               = "Global-MPG-Index"
    hash_key           = "Timestamp"
    range_key          = "Userid"  # Optional, but often useful for more complex queries
    projection_type    = "ALL" # ALL, INCLUDE, or KEYS_ONLY
    write_capacity     = 5     # If using PAY_PER_REQUEST, these are not needed
    read_capacity      = 5
  }

  # Use to set TTL for items
   ttl {
     attribute_name = "ttl"
     enabled        = true
   }

  # Use for encryption at rest with a KMS key
   server_side_encryption {
     enabled     = true
     kms_key_arn = data.aws_kms_key.dynamodb-key.arn
   }

  # Use to setup point-in-time restore
  # point_in_time_recovery {
  #   enabled = true
  # }

  # add tags
   tags = {
     Name = var.aws_dynamodb_table
     "BPOP:Owner" = "owner_tag"
     "BPOP:Organization" = "organization_tag"
     "BPOP:Cost-Center" = "cc_tag"
     "BPOP:Environment" = "environment_tag"
     "BPOP:App_Class" = "ac_tag"
     "BPOP:Application" = "application_tag"
     "BPOP:Data_Class" = "dc_tag"
     "BPOP:Backups" = "backups_tag"
     "BPOP:Usage_Schedule" = "usage_tag"
     "BPOP:Business_Continuity" = "bc_tag"
     "BPOP:Risk_Level" = "risk_tag"
   }
}

# CloudWatch alarm for DynamoDB consumed read capacity units
resource "aws_cloudwatch_metric_alarm" "read_capacity_usage" {
  alarm_name          = "${var.aws_dynamodb_table}-ConsumedReadCapacityUnits"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.read_capacity * 0.7 # Alert at 70% usage
  alarm_description   = "This alarm monitors the consumed read capacity units for ${var.aws_dynamodb_table}"
  alarm_actions       = [] # Add SNS topic ARN here for notifications

  dimensions = {
    TableName = var.aws_dynamodb_table
  }
}

# CloudWatch alarm for DynamoDB consumed write capacity units
resource "aws_cloudwatch_metric_alarm" "write_capacity_usage" {
  alarm_name          = "${var.aws_dynamodb_table}-ConsumedWriteCapacityUnits"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ConsumedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.write_capacity * 0.7 # Alert at 70% usage
  alarm_description   = "This alarm monitors the consumed write capacity units for ${var.aws_dynamodb_table}"
  alarm_actions       = [] # Add SNS topic ARN here for notifications

  dimensions = {
    TableName = var.aws_dynamodb_table
  }
}