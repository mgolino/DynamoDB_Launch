
variable "aws_kms_key" {
  type = string
  description = "KMS Key to encrypt the DynamoDB table"
  default = "alias/dynamodb-key"
}

variable "aws_dynamodb_table" {
  type = string
  description = "DynamoDB table to store Terraform state"
  default = "mpg-dynamoDB_app1"
}

variable "read_capacity" {
  type = number
  description = "Read capacity of the DynamoDB table"
  default = 5
}
  
variable "write_capacity" {
  type = number
  description = "Write capacity of the DynamoDB table"
  default = 5
}

