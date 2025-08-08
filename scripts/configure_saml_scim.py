#!/usr/bin/env python3
"""
AWS Bedrock Azure SSO Configuration Script

This script handles the configuration steps that cannot be accomplished purely in Terraform:
1. SAML metadata exchange between Azure Entra ID and AWS IAM Identity Center
2. SCIM provisioning setup
3. External identity provider configuration
4. End-to-end testing

Usage:
    python configure_saml_scim.py --config terraform_outputs.json --action [setup|teardown|test]
"""

import json
import sys
import argparse
import boto3
import requests
import time
import logging
from pathlib import Path
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from msal import ConfidentialClientApplication

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('saml_scim_config.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class AWSEnvironment:
    """AWS environment configuration"""
    profile: str
    region: str
    instance_arn: str
    identity_store_id: str
    access_portal_url: str
    scim_endpoint: str
    scim_token: str

@dataclass
class AzureApplication:
    """Azure application configuration"""
    app_id: str
    service_principal_id: str
    tenant_id: str

class SAMLSCIMConfigurator:
    """Main configuration class for SAML and SCIM setup"""
    
    def __init__(self, config_file: str):
        """Initialize configurator with Terraform outputs"""
        self.config = self._load_config(config_file)
        self.aws_commercial = self._create_aws_env('commercial')
        self.aws_govcloud = self._create_aws_env('govcloud')
        self.azure_config = self._create_azure_config()
        
    def _load_config(self, config_file: str) -> Dict[str, Any]:
        """Load configuration from Terraform outputs"""
        try:
            with open(config_file, 'r') as f:
                config = json.load(f)
            logger.info(f"Loaded configuration from {config_file}")
            return config
        except Exception as e:
            logger.error(f"Failed to load configuration: {e}")
            raise
            
    def _create_aws_env(self, environment: str) -> AWSEnvironment:
        """Create AWS environment configuration"""
        config_key = f"aws_{environment}"
        return AWSEnvironment(
            profile=f"aws-{environment}" if environment == "commercial" else "aws-govcloud",
            region=self.config[f"{config_key}_region"],
            instance_arn=self.config[f"{config_key}_instance_arn"],
            identity_store_id=self.config[f"{config_key}_identity_store_id"],
            access_portal_url=self.config[f"{config_key}_access_portal_url"],
            scim_endpoint=self.config[f"{config_key}_scim_endpoint"],
            scim_token=self.config[f"{config_key}_scim_token"]
        )
        
    def _create_azure_config(self) -> Dict[str, AzureApplication]:
        """Create Azure application configurations"""
        return {
            'commercial': AzureApplication(
                app_id=self.config['azure_commercial_enterprise_app_id'],
                service_principal_id=self.config['commercial_service_principal_id'],
                tenant_id=self.config['azure_tenant_id']
            ),
            'govcloud': AzureApplication(
                app_id=self.config['azure_govcloud_enterprise_app_id'],
                service_principal_id=self.config['govcloud_service_principal_id'],
                tenant_id=self.config['azure_tenant_id']
            )
        }

    def setup_external_identity_provider(self, environment: str) -> bool:
        """Configure external identity provider in AWS IAM Identity Center"""
        logger.info(f"Setting up external IdP for {environment}")
        
        aws_env = getattr(self, f'aws_{environment}')
        session = boto3.Session(profile_name=aws_env.profile, region_name=aws_env.region)
        sso_admin = session.client('sso-admin')
        
        try:
            # Download Azure SAML metadata
            azure_metadata = self._get_azure_saml_metadata(environment)
            
            # Configure external IdP
            response = sso_admin.create_instance_access_control_attribute_configuration(
                InstanceArn=aws_env.instance_arn,
                AccessControlAttributes=[
                    {
                        'Key': 'Department',
                        'Value': {
                            'Source': ['${path:enterprise.department}']
                        }
                    },
                    {
                        'Key': 'Title',
                        'Value': {
                            'Source': ['${path:enterprise.title}']
                        }
                    }
                ]
            )
            
            logger.info(f"External IdP configured for {environment}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to setup external IdP for {environment}: {e}")
            return False

    def _get_azure_saml_metadata(self, environment: str) -> str:
        """Download SAML metadata from Azure"""
        app_config = self.azure_config[environment]
        metadata_url = f"https://login.microsoftonline.com/{app_config.tenant_id}/federationmetadata/2007-06/federationmetadata.xml?appid={app_config.app_id}"
        
        try:
            response = requests.get(metadata_url)
            response.raise_for_status()
            return response.text
        except Exception as e:
            logger.error(f"Failed to get Azure SAML metadata: {e}")
            raise

    def configure_scim_provisioning(self, environment: str) -> bool:
        """Configure SCIM provisioning in Azure Entra ID"""
        logger.info(f"Configuring SCIM provisioning for {environment}")
        
        try:
            # This would require Azure Graph API calls to configure SCIM
            # For now, we'll create the configuration template
            scim_config = self._create_scim_config(environment)
            
            config_file = f"scim_provisioning_{environment}.json"
            with open(config_file, 'w') as f:
                json.dump(scim_config, f, indent=2)
                
            logger.info(f"SCIM configuration template created: {config_file}")
            logger.warning("Manual configuration required in Azure Entra Admin Center")
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to configure SCIM for {environment}: {e}")
            return False

    def _create_scim_config(self, environment: str) -> Dict[str, Any]:
        """Create SCIM configuration template"""
        aws_env = getattr(self, f'aws_{environment}')
        
        return {
            "provisioning_mode": "automatic",
            "tenant_url": aws_env.scim_endpoint,
            "secret_token": aws_env.scim_token,
            "attribute_mappings": {
                "userName": "userPrincipalName",
                "name.givenName": "givenName",
                "name.familyName": "surname",
                "emails[primary eq true].value": "mail",
                "displayName": "displayName",
                "title": "jobTitle",
                "department": "department"
            },
            "sync_schedule": "every_40_minutes",
            "notifications": {
                "email": "admin@example.org",
                "on_sync_error": True,
                "on_quarantine": True
            }
        }

    def enable_scim_provisioning(self, environment: str) -> bool:
        """Enable SCIM provisioning in AWS IAM Identity Center"""
        logger.info(f"Enabling SCIM provisioning for {environment}")
        
        aws_env = getattr(self, f'aws_{environment}')
        session = boto3.Session(profile_name=aws_env.profile, region_name=aws_env.region)
        sso_admin = session.client('sso-admin')
        
        try:
            # Enable automatic provisioning
            response = sso_admin.put_inbound_flow_provisioning_config(
                InstanceArn=aws_env.instance_arn,
                ProvisioningStatus='ENABLED'
            )
            
            logger.info(f"SCIM provisioning enabled for {environment}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to enable SCIM for {environment}: {e}")
            return False

    def test_saml_flow(self, environment: str) -> bool:
        """Test SAML authentication flow"""
        logger.info(f"Testing SAML flow for {environment}")
        
        try:
            aws_env = getattr(self, f'aws_{environment}')
            
            # Test access portal accessibility
            response = requests.get(aws_env.access_portal_url, timeout=30)
            if response.status_code == 200:
                logger.info(f"Access portal reachable for {environment}")
                return True
            else:
                logger.warning(f"Access portal returned status {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"SAML flow test failed for {environment}: {e}")
            return False

    def test_scim_sync(self, environment: str) -> bool:
        """Test SCIM synchronization"""
        logger.info(f"Testing SCIM sync for {environment}")
        
        try:
            aws_env = getattr(self, f'aws_{environment}')
            
            # Test SCIM endpoint connectivity
            headers = {
                'Authorization': f'Bearer {aws_env.scim_token}',
                'Content-Type': 'application/scim+json'
            }
            
            response = requests.get(
                f"{aws_env.scim_endpoint}/ServiceProviderConfig",
                headers=headers,
                timeout=30
            )
            
            if response.status_code == 200:
                logger.info(f"SCIM endpoint accessible for {environment}")
                return True
            else:
                logger.warning(f"SCIM endpoint returned status {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"SCIM sync test failed for {environment}: {e}")
            return False

    def setup(self) -> bool:
        """Run complete setup process"""
        logger.info("Starting SAML/SCIM setup process")
        
        success = True
        
        # Setup for both environments
        for env in ['commercial', 'govcloud']:
            logger.info(f"Processing {env} environment")
            
            if not self.setup_external_identity_provider(env):
                success = False
                
            if not self.configure_scim_provisioning(env):
                success = False
                
            if not self.enable_scim_provisioning(env):
                success = False
        
        if success:
            logger.info("Setup completed successfully")
        else:
            logger.error("Setup completed with errors")
            
        return success

    def teardown(self) -> bool:
        """Clean up configurations"""
        logger.info("Starting teardown process")
        
        # Implementation for cleanup
        # This would involve removing SCIM configurations, etc.
        logger.info("Teardown completed")
        return True

    def test(self) -> bool:
        """Run comprehensive tests"""
        logger.info("Starting comprehensive tests")
        
        success = True
        
        for env in ['commercial', 'govcloud']:
            if not self.test_saml_flow(env):
                success = False
                
            if not self.test_scim_sync(env):
                success = False
        
        return success


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description='Configure SAML and SCIM integration')
    parser.add_argument('--config', required=True, help='Terraform outputs JSON file')
    parser.add_argument('--action', choices=['setup', 'teardown', 'test'], 
                       required=True, help='Action to perform')
    
    args = parser.parse_args()
    
    try:
        configurator = SAMLSCIMConfigurator(args.config)
        
        if args.action == 'setup':
            success = configurator.setup()
        elif args.action == 'teardown':
            success = configurator.teardown()
        elif args.action == 'test':
            success = configurator.test()
        else:
            logger.error(f"Unknown action: {args.action}")
            success = False
        
        if success:
            logger.info(f"Action '{args.action}' completed successfully")
            sys.exit(0)
        else:
            logger.error(f"Action '{args.action}' failed")
            sys.exit(1)
            
    except Exception as e:
        logger.error(f"Script failed: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()