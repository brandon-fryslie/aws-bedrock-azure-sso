variable "environment" {
  description = "Environment name (commercial or govcloud)"
  type        = string
  validation {
    condition     = contains(["commercial", "govcloud"], var.environment)
    error_message = "Environment must be either 'commercial' or 'govcloud'."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
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

variable "enable_scim" {
  description = "Enable SCIM synchronization"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}