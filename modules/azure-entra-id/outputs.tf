# Enterprise Application IDs
output "commercial_enterprise_app_id" {
  description = "Azure Enterprise Application ID for AWS Commercial"
  value       = azurerm_application.aws_commercial.application_id
}

output "govcloud_enterprise_app_id" {
  description = "Azure Enterprise Application ID for AWS GovCloud"
  value       = azurerm_application.aws_govcloud.application_id
}

# Service Principal IDs
output "commercial_service_principal_id" {
  description = "Service Principal ID for AWS Commercial enterprise app"
  value       = azurerm_service_principal.aws_commercial.object_id
}

output "govcloud_service_principal_id" {
  description = "Service Principal ID for AWS GovCloud enterprise app"
  value       = azurerm_service_principal.aws_govcloud.object_id
}

# Test user details
output "test_user_ids" {
  description = "Map of test user names to their Azure AD object IDs"
  value       = { for username, user in azurerm_user.test_users : username => user.object_id }
}

output "test_user_principals" {
  description = "Map of test user names to their user principal names"
  value       = { for username, user in azurerm_user.test_users : username => user.user_principal_name }
}

# User passwords (sensitive)
output "test_user_passwords" {
  description = "Map of test user names to their generated passwords"
  value       = { for username, pwd in random_password.user_passwords : username => pwd.result }
  sensitive   = true
}

# Configuration URLs for manual steps
output "my_account_portal_url" {
  description = "Microsoft My Account portal URL for testing"
  value       = "https://myaccount.microsoft.com/"
}

output "entra_admin_center_url" {
  description = "Microsoft Entra admin center URL"
  value       = "https://entra.microsoft.com/"
}

# Configuration status
output "configuration_status" {
  description = "Status of Azure Entra ID configuration"
  value = {
    tenant_id                     = var.tenant_id
    users_created                 = length(var.test_users)
    enterprise_apps_created       = 2
    user_assignments_completed    = length(var.test_users) * 2
    manual_steps_required = [
      "Configure SAML SSO settings via Python script",
      "Upload AWS SAML metadata files via Python script", 
      "Configure SCIM provisioning via Python script",
      "Test authentication flows",
      "Configure attribute mappings for ABAC"
    ]
  }
}