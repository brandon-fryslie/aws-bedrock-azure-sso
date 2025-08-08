# AWS Bedrock Azure SSO Integration Module
# Implements SAML and SCIM integration between Microsoft Entra ID and AWS IAM Identity Center
# across AWS Commercial, AWS GovCloud, and Azure

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.commercial, aws.govcloud]
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# AWS Commercial Provider
provider "aws" {
  alias   = "commercial"
  profile = "aws-commercial"
  region  = "us-east-1"
}

# AWS GovCloud Provider
provider "aws" {
  alias   = "govcloud"
  profile = "aws-govcloud"
  region  = "us-gov-west-1"
}

# Azure Provider
provider "azurerm" {
  features {}
  
  # Using nickname 'azure-identity-provider' or 'azure-id'
  # Assumes credentials are configured externally
}

# Module: AWS Commercial IAM Identity Center Configuration
module "aws_commercial_identity_center" {
  source = "./modules/aws-identity-center"
  
  providers = {
    aws = aws.commercial
  }
  
  environment = "commercial"
  region      = "us-east-1"
  
  test_users = var.test_users
  enable_scim = var.enable_scim
  
  tags = merge(var.common_tags, {
    Environment = "commercial"
    Purpose     = "azure-sso-integration"
  })
}

# Module: AWS GovCloud IAM Identity Center Configuration
module "aws_govcloud_identity_center" {
  source = "./modules/aws-identity-center"
  
  providers = {
    aws = aws.govcloud
  }
  
  environment = "govcloud"
  region      = "us-gov-west-1"
  
  test_users = var.test_users
  enable_scim = var.enable_scim
  
  tags = merge(var.common_tags, {
    Environment = "govcloud"
    Purpose     = "azure-sso-integration"
  })
}

# Module: Azure Entra ID Configuration
module "azure_entra_id" {
  source = "./modules/azure-entra-id"
  
  tenant_id = var.azure_tenant_id
  test_users = var.test_users
  
  # SAML endpoints from AWS Identity Centers
  aws_commercial_saml_metadata_url = module.aws_commercial_identity_center.saml_metadata_url
  aws_commercial_signin_url = module.aws_commercial_identity_center.signin_url
  aws_govcloud_saml_metadata_url = module.aws_govcloud_identity_center.saml_metadata_url
  aws_govcloud_signin_url = module.aws_govcloud_identity_center.signin_url
  
  tags = merge(var.common_tags, {
    Environment = "azure-identity-provider"
    Purpose     = "aws-sso-integration"
  })
}

# Module: SCIM Synchronization Configuration
module "scim_sync" {
  source = "./modules/scim-sync"
  
  # SCIM endpoints from AWS Identity Centers
  aws_commercial_scim_endpoint = module.aws_commercial_identity_center.scim_endpoint
  aws_commercial_scim_token = module.aws_commercial_identity_center.scim_access_token
  aws_govcloud_scim_endpoint = module.aws_govcloud_identity_center.scim_endpoint
  aws_govcloud_scim_token = module.aws_govcloud_identity_center.scim_access_token
  
  # Azure enterprise application details
  azure_enterprise_app_commercial_id = module.azure_entra_id.commercial_enterprise_app_id
  azure_enterprise_app_govcloud_id = module.azure_entra_id.govcloud_enterprise_app_id
  
  depends_on = [
    module.aws_commercial_identity_center,
    module.aws_govcloud_identity_center,
    module.azure_entra_id
  ]
}