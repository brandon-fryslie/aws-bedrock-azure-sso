#!/bin/bash
set -e

# AWS Bedrock Azure SSO Teardown Script
# Safely removes all deployed resources

echo "=== AWS Bedrock Azure SSO Teardown ==="
echo ""

# Warning prompt
echo "⚠️  WARNING: This will destroy all deployed resources!"
echo "This includes:"
echo "- AWS IAM Identity Center configurations"
echo "- Azure Entra ID enterprise applications and users"
echo "- Permission sets and account assignments"
echo "- SCIM provisioning configurations"
echo ""

read -p "Are you sure you want to proceed with teardown? (type 'yes' to confirm): " -r
if [[ ! $REPLY == "yes" ]]; then
    echo "Teardown cancelled"
    exit 1
fi

echo ""
echo "Starting teardown process..."
echo ""

# Phase 1: Python Script Cleanup
echo "=== Phase 1: SCIM and SAML Cleanup ==="
echo ""

if [ -f "terraform_outputs.json" ]; then
    echo "Running Python cleanup script..."
    cd scripts
    python3 configure_saml_scim.py --config ../terraform_outputs.json --action teardown || {
        echo "⚠️  Python script cleanup encountered issues, continuing with Terraform teardown..."
    }
    cd ..
else
    echo "⚠️  terraform_outputs.json not found, skipping Python cleanup"
fi

echo "✓ Python script cleanup completed"
echo ""

# Phase 2: Terraform Destruction
echo "=== Phase 2: Terraform Infrastructure Teardown ==="
echo ""

echo "Planning Terraform destruction..."
terraform plan -destroy

echo ""
read -p "Do you want to proceed with Terraform destroy? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Teardown cancelled"
    exit 1
fi

echo "Destroying Terraform infrastructure..."
terraform destroy -auto-approve

echo "✓ Terraform destruction completed"
echo ""

# Phase 3: Cleanup Generated Files
echo "=== Phase 3: Cleanup Generated Files ==="
echo ""

echo "Removing generated configuration files..."

# Remove Terraform outputs
if [ -f "terraform_outputs.json" ]; then
    rm terraform_outputs.json
    echo "✓ Removed terraform_outputs.json"
fi

# Remove SCIM configuration files
if [ -f "scim_config.json" ]; then
    rm scim_config.json
    echo "✓ Removed scim_config.json"
fi

if [ -f "scim_test_config.json" ]; then
    rm scim_test_config.json
    echo "✓ Removed scim_test_config.json"
fi

# Remove Python-generated configuration files
for file in scim_provisioning_*.json; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "✓ Removed $file"
    fi
done

# Remove log files
if [ -f "scripts/saml_scim_config.log" ]; then
    rm scripts/saml_scim_config.log
    echo "✓ Removed saml_scim_config.log"
fi

# Remove Terraform state backups (optional)
read -p "Remove Terraform state backup files? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f terraform.tfstate.backup*
    echo "✓ Removed Terraform state backups"
fi

echo ""
echo "=== Manual Cleanup Required ==="
echo ""
echo "The following may require manual cleanup:"
echo ""
echo "1. Azure Entra Admin Center:"
echo "   - Verify enterprise applications are removed"
echo "   - Check for any remaining user assignments"
echo "   - Review audit logs for cleanup verification"
echo ""
echo "2. AWS Identity Center:"
echo "   - Verify external IdP configurations are removed"
echo "   - Check SCIM provisioning is disabled"
echo "   - Review CloudTrail logs for cleanup verification"
echo ""
echo "3. Local Environment:"
echo "   - terraform.tfvars (preserved - contains your custom configuration)"
echo "   - AWS CLI profiles (preserved)"
echo "   - Azure CLI configuration (preserved)"
echo ""

echo "=== Teardown Summary ==="
echo ""
echo "✓ Python script cleanup completed"
echo "✓ Terraform infrastructure destroyed"
echo "✓ Generated configuration files removed"
echo "✓ Log files cleaned up"
echo ""
echo "📋 Remaining Items:"
echo "- Verify manual cleanup in Azure and AWS consoles"
echo "- Review audit logs for complete cleanup verification"
echo "- terraform.tfvars preserved for future deployments"
echo ""
echo "Teardown completed successfully!"
echo ""
echo "Note: To completely start fresh, you may also want to:"
echo "- Remove .terraform/ directory"
echo "- Remove terraform.tfstate files"
echo "- Reset your terraform.tfvars configuration"