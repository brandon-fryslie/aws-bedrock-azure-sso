# AWS Bedrock Azure SSO Deployment Guide

This document provides step-by-step instructions for deploying the AWS Bedrock Azure SSO integration using Terraform and Python scripts.

## Prerequisites

### AWS Prerequisites
- AWS CLI configured with profiles:
  - `aws-commercial`: AWS Commercial account credentials
  - `aws-govcloud`: AWS GovCloud account credentials
- AWS IAM Identity Center enabled in both accounts
- Appropriate IAM permissions to manage Identity Center resources

### Azure Prerequisites
- Azure CLI configured with appropriate permissions
- Azure Entra ID (Azure AD) tenant with admin access
- Application registration permissions

### Local Prerequisites
- Terraform >= 1.5
- Python >= 3.8
- Required Python packages (see `scripts/requirements.txt`)

## Deployment Process

### Phase 1: Terraform Infrastructure Deployment

#### 1. Initialize Terraform
```bash
terraform init
```

#### 2. Review and Customize Variables
Edit `terraform.tfvars` to customize your deployment:

```hcl
# terraform.tfvars
azure_tenant_id = "your-azure-tenant-id"
enable_scim = true
enable_abac = false  # Set to true if you want ABAC

test_users = [
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

common_tags = {
  Project     = "aws-bedrock-azure-sso"
  Environment = "production"
  ManagedBy   = "terraform"
  Owner       = "platform-team"
}
```

#### 3. Plan Deployment
```bash
terraform plan
```

#### 4. Deploy Infrastructure
```bash
terraform apply
```

This will create:
- AWS IAM Identity Center configurations in both commercial and GovCloud
- Azure Entra ID enterprise applications
- Test users in both systems
- Permission sets and account assignments
- ABAC configurations (if enabled)

#### 5. Export Terraform Outputs
```bash
terraform output -json > terraform_outputs.json
```

### Phase 2: Python Script Configuration

#### 1. Install Python Dependencies
```bash
pip install -r scripts/requirements.txt
```

#### 2. Configure SAML and SCIM
```bash
cd scripts
python configure_saml_scim.py --config ../terraform_outputs.json --action setup
```

This script will:
- Configure external identity provider in AWS IAM Identity Center
- Set up SAML metadata exchange
- Enable SCIM provisioning
- Create configuration templates for manual steps

#### 3. Manual Configuration Steps

The Python script will generate configuration files and instructions for manual steps that must be completed in the Azure Entra Admin Center:

1. **Upload SAML Metadata**: 
   - Download metadata files from AWS IAM Identity Center
   - Upload to Azure enterprise applications

2. **Configure SCIM Provisioning**:
   - Use generated `scim_provisioning_*.json` files
   - Configure in Azure Entra Admin Center under Provisioning

3. **Set up Attribute Mappings**:
   - Configure attribute mappings for ABAC (if enabled)
   - Set up claims in SAML assertions

### Phase 3: Testing and Validation

#### 1. Run Automated Tests
```bash
python configure_saml_scim.py --config ../terraform_outputs.json --action test
```

#### 2. Manual Testing
1. Navigate to https://myaccount.microsoft.com/
2. Sign in with test user credentials
3. Access AWS IAM Identity Center applications
4. Verify SAML authentication flow
5. Test SCIM user synchronization

## Component Details

### Terraform-Managed Components

#### AWS Components (Both Commercial and GovCloud)
- **IAM Identity Center Instance**: Existing instance configuration
- **Test Users**: Created in Identity Store
- **Permission Sets**: 
  - `RegionalAdmin`: Limited regional management permissions
  - `AdministratorAccess`: Full administrative permissions
  - `ABACDepartmentAccess`: Department-based ABAC permissions (optional)
  - `ABACTitleAccess`: Title-based ABAC permissions (optional)
- **Account Assignments**: Users assigned to permission sets

#### Azure Components
- **Enterprise Applications**: 
  - AWS IAM Identity Center - Commercial
  - AWS IAM Identity Center - GovCloud
- **Test Users**: Created in Azure AD
- **App Role Assignments**: Users assigned to enterprise applications

### Python Script-Managed Components

#### SAML Configuration
- External identity provider setup in AWS
- SAML metadata exchange
- SSO endpoint configuration

#### SCIM Configuration
- SCIM endpoint enablement in AWS
- Provisioning configuration in Azure
- Attribute mapping setup
- Sync schedule configuration

## Teardown Process

### 1. Run Python Cleanup
```bash
python configure_saml_scim.py --config terraform_outputs.json --action teardown
```

### 2. Destroy Terraform Infrastructure
```bash
terraform destroy
```

## Manual Steps Required

### Azure Entra Admin Center Configuration

The following steps must be completed manually in the Azure Entra Admin Center:

1. **SAML SSO Configuration**:
   - Navigate to Enterprise Applications
   - Select AWS IAM Identity Center applications
   - Configure Single Sign-On settings
   - Upload SAML metadata files

2. **SCIM Provisioning Setup**:
   - Enable automatic provisioning
   - Configure tenant URL and secret token
   - Set up attribute mappings
   - Start provisioning

3. **Attribute Claims Configuration** (for ABAC):
   - Add claims for Department and Title attributes
   - Configure namespace: `https://aws.amazon.com/SAML/Attributes`
   - Map Azure AD attributes to SAML claims

### AWS IAM Identity Center Configuration

Most AWS configuration is handled by Terraform, but the following may require manual verification:

1. **External Identity Provider**:
   - Verify IdP configuration in Settings
   - Confirm SAML metadata upload

2. **SCIM Provisioning**:
   - Verify automatic provisioning is enabled
   - Check SCIM endpoint accessibility

## Troubleshooting

### Common Issues

1. **SAML Authentication Failures**:
   - Verify metadata files are correctly uploaded
   - Check sign-in URLs match between Azure and AWS
   - Validate certificate configurations

2. **SCIM Synchronization Issues**:
   - Verify SCIM endpoints are accessible
   - Check access token validity
   - Review attribute mappings
   - Monitor provisioning logs in Azure

3. **Permission Issues**:
   - Verify user assignments to permission sets
   - Check account assignments in AWS
   - Validate ABAC attribute configurations

### Log Files
- Terraform: Check terraform plan/apply output
- Python Script: Review `saml_scim_config.log`
- Azure: Monitor provisioning logs in Entra Admin Center
- AWS: Check CloudTrail logs for SSO-related events

## Security Considerations

1. **Credential Management**:
   - SCIM tokens are sensitive - store securely
   - User passwords are auto-generated and marked for change
   - Use least-privilege principle for service accounts

2. **Network Security**:
   - SAML and SCIM use HTTPS encryption
   - Consider network restrictions for admin endpoints
   - Monitor authentication attempts

3. **Audit and Compliance**:
   - Enable CloudTrail logging for AWS resources
   - Monitor Azure AD sign-in logs
   - Review permission assignments regularly
   - Implement regular access reviews

## Support and Maintenance

### Regular Maintenance Tasks
1. Review and rotate SCIM access tokens quarterly
2. Audit user access and permission assignments monthly
3. Update attribute mappings as needed
4. Monitor synchronization logs for errors

### Configuration Updates
- Use Terraform for infrastructure changes
- Test changes in non-production environment first
- Coordinate Azure and AWS configuration updates

For additional support, refer to the AWS IAM Identity Center documentation and Azure Entra ID integration guides.