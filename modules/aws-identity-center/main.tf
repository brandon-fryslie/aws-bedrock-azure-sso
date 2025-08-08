# AWS IAM Identity Center Module
# Configures IAM Identity Center for SAML and SCIM integration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source to get the Identity Center instance
data "aws_ssoadmin_instances" "main" {}

locals {
  identity_center_instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  identity_center_identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}

# Create test users in Identity Center
resource "aws_identitystore_user" "test_users" {
  for_each = { for user in var.test_users : user.username => user }
  
  identity_store_id = local.identity_center_identity_store_id
  
  display_name = "${each.value.first_name} ${each.value.last_name}"
  user_name    = each.value.username
  
  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }
  
  emails {
    value   = each.value.email
    primary = true
    type    = "work"
  }
  
  # Optional attributes
  dynamic "addresses" {
    for_each = each.value.department != null ? [1] : []
    content {
      type            = "work"
      street_address  = "Department: ${each.value.department}"
    }
  }
  
  title = each.value.title
  
  tags = var.tags
}

# Create RegionalAdmin permission set as described in the tutorial
resource "aws_ssoadmin_permission_set" "regional_admin" {
  name             = "RegionalAdmin"
  description      = "Permission set for regional administration tasks"
  instance_arn     = local.identity_center_instance_arn
  session_duration = "PT1H"
  
  tags = var.tags
}

# Create inline policy for RegionalAdmin permission set
resource "aws_ssoadmin_permission_set_inline_policy" "regional_admin_policy" {
  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.regional_admin.arn
  
  inline_policy = jsonencode({
    Statement = [
      {
        Sid    = "Statement1"
        Effect = "Allow"
        Action = [
          "account:ListRegions",
          "account:DisableRegion", 
          "account:EnableRegion",
          "account:GetRegionOptStatus"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Create Administrator permission set for testing
resource "aws_ssoadmin_permission_set" "administrator_access" {
  name             = "AdministratorAccess"
  description      = "Administrator access permission set"
  instance_arn     = local.identity_center_instance_arn
  session_duration = "PT1H"
  
  tags = var.tags
}

# Attach AWS managed AdministratorAccess policy
resource "aws_ssoadmin_managed_policy_attachment" "administrator_access" {
  instance_arn       = local.identity_center_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.administrator_access.arn
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Account assignment for test users to permission sets
resource "aws_ssoadmin_account_assignment" "nikki_wolf_regional_admin" {
  count = length([for user in var.test_users : user if user.username == "NikkiWolf"]) > 0 ? 1 : 0
  
  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.regional_admin.arn
  
  principal_id   = aws_identitystore_user.test_users["NikkiWolf"].user_id
  principal_type = "USER"
  
  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
  
  depends_on = [aws_identitystore_user.test_users]
}

resource "aws_ssoadmin_account_assignment" "rich_roe_admin" {
  count = length([for user in var.test_users : user if user.username == "RichRoe"]) > 0 ? 1 : 0
  
  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator_access.arn
  
  principal_id   = aws_identitystore_user.test_users["RichRoe"].user_id
  principal_type = "USER"
  
  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
  
  depends_on = [aws_identitystore_user.test_users]
}

# External Identity Provider configuration (will be configured via Python script)
# This is a placeholder as the external IdP configuration requires manual steps
resource "null_resource" "external_idp_placeholder" {
  count = 1
  
  provisioner "local-exec" {
    command = "echo 'External IdP configuration will be handled by Python script'"
  }
  
  triggers = {
    instance_arn = local.identity_center_instance_arn
  }
}

# SCIM provisioning configuration
resource "null_resource" "scim_provisioning" {
  count = var.enable_scim ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'SCIM provisioning will be configured via Python script'"
  }
  
  triggers = {
    instance_arn = local.identity_center_instance_arn
    enable_scim  = var.enable_scim
  }
}