# Configuration file paths
output "scim_config_file" {
  description = "Path to SCIM configuration file for Python script"
  value       = local_file.scim_config.filename
}

output "scim_test_config_file" {
  description = "Path to SCIM test configuration file"
  value       = local_file.scim_test_config.filename
}

# Configuration status
output "configuration_status" {
  description = "Status of SCIM synchronization configuration"
  value = {
    commercial_configured = true
    govcloud_configured   = true
    config_files_created  = 2
    python_script_required = true
    manual_steps_required = [
      "Run Python script to configure SCIM provisioning",
      "Test user synchronization", 
      "Verify attribute mappings",
      "Monitor sync logs"
    ]
  }
}

# SCIM endpoints (for reference)
output "scim_endpoints" {
  description = "SCIM endpoints for both environments"
  value = {
    commercial = var.aws_commercial_scim_endpoint
    govcloud   = var.aws_govcloud_scim_endpoint
  }
  sensitive = false
}