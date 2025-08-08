# Azure Entra ID Module
# Configures Enterprise Applications for AWS IAM Identity Center integration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Data source for current Azure client config
data "azurerm_client_config" "current" {}

# Create test users in Azure AD
resource "azurerm_user" "test_users" {
  for_each = { for user in var.test_users : user.username => user }
  
  user_principal_name   = "${each.value.username}@${var.tenant_domain}"
  display_name          = "${each.value.first_name} ${each.value.last_name}"
  given_name           = each.value.first_name
  surname              = each.value.last_name
  mail_nickname        = each.value.username
  password             = random_password.user_passwords[each.key].result
  force_password_change = true
  
  # Optional attributes
  department = each.value.department
  job_title  = each.value.title
  
  tags = var.tags
}

# Generate random passwords for test users
resource "random_password" "user_passwords" {
  for_each = { for user in var.test_users : user.username => user }
  
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Enterprise application for AWS Commercial
resource "azurerm_application" "aws_commercial" {
  display_name = "AWS IAM Identity Center - Commercial"
  
  web {
    redirect_uris = [
      var.aws_commercial_signin_url,
      "${var.aws_commercial_signin_url}/saml"
    ]
  }
  
  # SAML configuration
  app_role {
    allowed_member_types = ["User"]
    description          = "User access to AWS Commercial"
    display_name         = "User"
    enabled              = true
    id                   = "18d14569-c3bd-439b-9a66-3a2aee01d14f"
    value                = "user"
  }
  
  tags = [for k, v in var.tags : "${k}=${v}"]
}

# Service principal for AWS Commercial enterprise app
resource "azurerm_service_principal" "aws_commercial" {
  application_id               = azurerm_application.aws_commercial.application_id
  app_role_assignment_required = true
  
  tags = [for k, v in var.tags : "${k}=${v}"]
}

# Enterprise application for AWS GovCloud  
resource "azurerm_application" "aws_govcloud" {
  display_name = "AWS IAM Identity Center - GovCloud"
  
  web {
    redirect_uris = [
      var.aws_govcloud_signin_url,
      "${var.aws_govcloud_signin_url}/saml"
    ]
  }
  
  # SAML configuration
  app_role {
    allowed_member_types = ["User"]
    description          = "User access to AWS GovCloud"
    display_name         = "User"  
    enabled              = true
    id                   = "28d14569-c3bd-439b-9a66-3a2aee01d14f"
    value                = "user"
  }
  
  tags = [for k, v in var.tags : "${k}=${v}"]
}

# Service principal for AWS GovCloud enterprise app
resource "azurerm_service_principal" "aws_govcloud" {
  application_id               = azurerm_application.aws_govcloud.application_id
  app_role_assignment_required = true
  
  tags = [for k, v in var.tags : "${k}=${v}"]
}

# Assign test users to AWS Commercial enterprise app
resource "azurerm_app_role_assignment" "aws_commercial_users" {
  for_each = { for user in var.test_users : user.username => user }
  
  assignee_object_id   = azurerm_user.test_users[each.key].object_id
  app_role_id          = azurerm_application.aws_commercial.app_role[0].id
  resource_object_id   = azurerm_service_principal.aws_commercial.object_id
}

# Assign test users to AWS GovCloud enterprise app  
resource "azurerm_app_role_assignment" "aws_govcloud_users" {
  for_each = { for user in var.test_users : user.username => user }
  
  assignee_object_id   = azurerm_user.test_users[each.key].object_id
  app_role_id          = azurerm_application.aws_govcloud.app_role[0].id
  resource_object_id   = azurerm_service_principal.aws_govcloud.object_id
}

# Placeholder resources for configurations that require Python scripts
resource "null_resource" "saml_configuration" {
  count = 1
  
  provisioner "local-exec" {
    command = "echo 'SAML configuration will be handled by Python script'"
  }
  
  triggers = {
    commercial_app_id = azurerm_application.aws_commercial.application_id
    govcloud_app_id   = azurerm_application.aws_govcloud.application_id
  }
}

resource "null_resource" "scim_configuration" {
  count = 1
  
  provisioner "local-exec" {
    command = "echo 'SCIM provisioning configuration will be handled by Python script'"
  }
  
  triggers = {
    commercial_sp_id = azurerm_service_principal.aws_commercial.object_id
    govcloud_sp_id   = azurerm_service_principal.aws_govcloud.object_id
  }
}