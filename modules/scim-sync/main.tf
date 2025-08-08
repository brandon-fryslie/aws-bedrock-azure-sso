# SCIM Synchronization Module
# Handles SCIM provisioning configuration between Azure Entra ID and AWS IAM Identity Center

terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# SCIM configuration for AWS Commercial
resource "null_resource" "scim_commercial_config" {
  provisioner "local-exec" {
    command = "echo 'SCIM configuration for AWS Commercial will be handled by Python script'"
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Cleaning up SCIM configuration for AWS Commercial'"
  }
  
  triggers = {
    scim_endpoint = var.aws_commercial_scim_endpoint
    app_id        = var.azure_enterprise_app_commercial_id
  }
}

# SCIM configuration for AWS GovCloud
resource "null_resource" "scim_govcloud_config" {
  provisioner "local-exec" {
    command = "echo 'SCIM configuration for AWS GovCloud will be handled by Python script'"
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Cleaning up SCIM configuration for AWS GovCloud'"
  }
  
  triggers = {
    scim_endpoint = var.aws_govcloud_scim_endpoint
    app_id        = var.azure_enterprise_app_govcloud_id
  }
}

# Data file for Python script configuration
resource "local_file" "scim_config" {
  filename = "${path.root}/scim_config.json"
  content = jsonencode({
    aws_commercial = {
      scim_endpoint = var.aws_commercial_scim_endpoint
      scim_token    = var.aws_commercial_scim_token
      app_id        = var.azure_enterprise_app_commercial_id
    }
    aws_govcloud = {
      scim_endpoint = var.aws_govcloud_scim_endpoint
      scim_token    = var.aws_govcloud_scim_token
      app_id        = var.azure_enterprise_app_govcloud_id
    }
    configuration = {
      provisioning_mode = "automatic"
      sync_frequency    = "40 minutes"
      attributes = {
        user_attributes = [
          "userName",
          "name.givenName", 
          "name.familyName",
          "emails[primary eq true].value",
          "displayName",
          "title",
          "department"
        ]
        group_attributes = [
          "displayName",
          "members"
        ]
      }
      mappings = {
        azure_to_aws = {
          "userPrincipalName" = "userName"
          "givenName"         = "name.givenName"
          "surname"           = "name.familyName"  
          "mail"              = "emails[primary eq true].value"
          "displayName"       = "displayName"
          "jobTitle"          = "title"
          "department"        = "department"
        }
      }
    }
  })
  
  file_permission = "0600"
}

# Test configuration file for validation
resource "local_file" "scim_test_config" {
  filename = "${path.root}/scim_test_config.json"
  content = jsonencode({
    test_scenarios = [
      {
        name        = "user_sync_test"
        description = "Test user synchronization from Azure to AWS"
        test_user   = "RichRoe"
        expected_attributes = [
          "userName",
          "name.givenName",
          "name.familyName", 
          "emails",
          "displayName"
        ]
      },
      {
        name        = "attribute_mapping_test"
        description = "Test attribute mapping correctness"
        test_attributes = {
          department = "Finance"
          title      = "Analyst"
        }
      }
    ]
    validation_endpoints = [
      "/Users",
      "/Groups", 
      "/ServiceProviderConfig",
      "/ResourceTypes",
      "/Schemas"
    ]
  })
  
  file_permission = "0600"
}