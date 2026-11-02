variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cost_center" {
  description = "Cost allocation center"
  type        = string
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
}
