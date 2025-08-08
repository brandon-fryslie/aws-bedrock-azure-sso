output "aws_commercial_access_portal_url" {
  description = "AWS Commercial Identity Center access portal URL"
  value       = module.aws_commercial_identity_center.access_portal_url
  sensitive   = false
}

output "aws_govcloud_access_portal_url" {
  description = "AWS GovCloud Identity Center access portal URL"
  value       = module.aws_govcloud_identity_center.access_portal_url
  sensitive   = false
}

output "aws_commercial_scim_endpoint" {
  description = "AWS Commercial SCIM endpoint for provisioning"
  value       = module.aws_commercial_identity_center.scim_endpoint
  sensitive   = false
}

output "aws_govcloud_scim_endpoint" {
  description = "AWS GovCloud SCIM endpoint for provisioning"
  value       = module.aws_govcloud_identity_center.scim_endpoint
  sensitive   = false
}

output "azure_commercial_enterprise_app_id" {
  description = "Azure Enterprise Application ID for AWS Commercial"
  value       = module.azure_entra_id.commercial_enterprise_app_id
  sensitive   = false
}

output "azure_govcloud_enterprise_app_id" {
  description = "Azure Enterprise Application ID for AWS GovCloud"
  value       = module.azure_entra_id.govcloud_enterprise_app_id
  sensitive   = false
}

# Sensitive outputs for manual configuration steps
output "aws_commercial_scim_token" {
  description = "AWS Commercial SCIM access token (sensitive)"
  value       = module.aws_commercial_identity_center.scim_access_token
  sensitive   = true
}

output "aws_govcloud_scim_token" {
  description = "AWS GovCloud SCIM access token (sensitive)"
  value       = module.aws_govcloud_identity_center.scim_access_token
  sensitive   = true
}

output "configuration_summary" {
  description = "Summary of configuration steps completed and pending"
  value = {
    terraform_managed = [
      "AWS Commercial IAM Identity Center setup",
      "AWS GovCloud IAM Identity Center setup", 
      "Azure Enterprise Applications creation",
      "Test user creation",
      "Permission sets configuration",
      "Basic SAML configuration"
    ]
    manual_steps_required = [
      "Download and upload SAML metadata files",
      "Configure SCIM provisioning in Azure",
      "Test SAML authentication flow",
      "Configure attribute mappings for ABAC",
      "Assign users to enterprise applications"
    ]
    python_script_handles = [
      "SAML metadata exchange",
      "SCIM provisioning setup",
      "End-to-end testing"
    ]
  }
}