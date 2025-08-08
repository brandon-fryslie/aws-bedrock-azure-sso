
variable "azure_tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "enable_scim" {
  description = "Enable SCIM synchronization"
  type        = bool
  default     = true
}

variable "enable_abac" {
  description = "Enable Attribute-Based Access Control (ABAC)"
  type        = bool
  default     = false
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
  default = [
    {
      username   = "NikkiWolf"
      first_name = "Nikki"
      last_name  = "Wolf"
      email      = "nikkiwolf@example.org"
      department = "IT"
      title      = "Regional Admin"
    },
    {
      username   = "RichRoe"
      first_name = "Richard"
      last_name  = "Roe"
      email      = "richroe@example.org"
      department = "Finance"
      title      = "Analyst"
    }
  ]
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "aws-bedrock-azure-sso"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
}