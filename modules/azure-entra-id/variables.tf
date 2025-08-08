variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "tenant_domain" {
  description = "Azure AD tenant domain (e.g., example.onmicrosoft.com)"
  type        = string
  default     = "example.onmicrosoft.com"
}

variable "test_users" {
  description = "Test users for SSO configuration"
  type = list(object({
    username    = string
    first_name  = string
    last_name   = string
    email       = string
    department  = optional(string)
    title       = optional(string)
  }))
  default = []
}

variable "aws_commercial_saml_metadata_url" {
  description = "AWS Commercial SAML metadata URL"
  type        = string
}

variable "aws_commercial_signin_url" {
  description = "AWS Commercial access portal sign-in URL"
  type        = string
}

variable "aws_govcloud_saml_metadata_url" {
  description = "AWS GovCloud SAML metadata URL"
  type        = string
}

variable "aws_govcloud_signin_url" {
  description = "AWS GovCloud access portal sign-in URL"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}