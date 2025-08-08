variable "aws_commercial_scim_endpoint" {
  description = "AWS Commercial SCIM endpoint URL"
  type        = string
}

variable "aws_commercial_scim_token" {
  description = "AWS Commercial SCIM access token"
  type        = string
  sensitive   = true
}

variable "aws_govcloud_scim_endpoint" {
  description = "AWS GovCloud SCIM endpoint URL"
  type        = string
}

variable "aws_govcloud_scim_token" {
  description = "AWS GovCloud SCIM access token"
  type        = string
  sensitive   = true
}

variable "azure_enterprise_app_commercial_id" {
  description = "Azure Enterprise Application ID for AWS Commercial"
  type        = string
}

variable "azure_enterprise_app_govcloud_id" {
  description = "Azure Enterprise Application ID for AWS GovCloud"
  type        = string
}