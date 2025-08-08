# Azure Resource Naming & Scope Reference

This table summarizes Azure resource naming requirements, organized by service category. Terraform resource types link to the official Registry docs where applicable. Scope indicates the level at which the name must be unique: Global (across Azure), Subscription, Resource Group, Tenant (Entra ID), or Parent Resource.

| Service Category           | Resource Type / Purpose            | Terraform Resource Type & Docs                                            | Unique Scope         | Notes |
|---------------------------|------------------------------------|---------------------------------------------------------------------------|----------------------|-------|
| **Global DNS‑bound PaaS** | Storage Account                    | [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | Global               | DNS endpoint; 3–24 lowercase alphanumeric :contentReference[oaicite:1]{index=1} |
|                           | Key Vault                          | [`azurerm_key_vault`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)           | Global               | DNS `vault.azure.net` endpoint :contentReference[oaicite:2]{index=2} |
|                           | App Service / Function App         | [`azurerm_app_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service), [`azurerm_function_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) | Global               | Global DNS: `*.azurewebsites.net` :contentReference[oaicite:3]{index=3} |
|                           | Container Registry                 | [`azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | Global               | `*.azurecr.io` endpoint |
| **Management & API**      | API Management Service             | —                                                                         | Global               | Global scope, starts/ends with alphanumeric :contentReference[oaicite:4]{index=4} |
| **Networking - Public**   | Public IP (Standard) (DNS label)   | [`azurerm_public_ip`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)           | Global (DNS label)   | Label must be globally unique :contentReference[oaicite:5]{index=5} |
| **Networking**            | Virtual Network (VNet)             | [`azurerm_virtual_network`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | Resource Group       | Unique within RG |
|                           | Subnet                             | [`azurerm_subnet`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                 | Parent Resource      | Unique within its VNet |
| **Compute**               | Virtual Machine (VM)               | [`azurerm_linux_virtual_machine`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | Resource Group       | Unique within RG |
|                           | VM Scale Set                       | [`azurerm_linux_virtual_machine_scale_set`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | Resource Group       | Unique within RG |
| **Core Infra**            | Resource Group                     | —                                                                         | Subscription          | Unique per subscription |
|                           | Load Balancer / App Gateway        | [`azurerm_lb`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb), [`azurerm_application_gateway`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | Resource Group | Scoped to RG |
| **Identity & Security**   | Managed Identity                   | [`azurerm_user_assigned_identity`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | Resource Group | Unique within RG |
|                           | Role Definition (custom)           | [`azurerm_role_definition`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | Subscription / Tenant | Unique per scope |
| **DNS**                   | Public DNS Zone                    | [`azurerm_dns_zone`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone)   | Global (DNS name)     | Fully qualified DNS name :contentReference[oaicite:6]{index=6} |
|                           | Private DNS Zone                   | [`azurerm_private_dns_zone`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | Global (DNS name)    | DNS unique, but can exist across scopes |
| **Entra Identity**        | App Registration                   | [`azuread_application`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application)   | Tenant               | `appId` unique, display name not unique |
|                           | Service Principal                  | [`azuread_service_principal`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | Tenant        | Unique objectId GUID |
|                           | User / Group / Directory Role      | [`azuread_user`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user), [`azuread_group`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group), [`azuread_directory_role`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) | Tenant | Must be unique within tenant |
| **Other PaaS / Analytics**| (e.g., Cosmos DB, Search, Cognitive, Batch, SignalR, Relay, Event Grid, Front Door) | — | Global               | DNS-bound services; globally unique names required (see Microsoft naming docs) :contentReference[oaicite:7]{index=7} |

---

### Notes:
- **Global scope**: name must be unique across all Azure instances (e.g., DNS endpoints).
- **Subscription scope**: unique within a subscription (e.g., resource groups).
- **Resource Group scope**: unique within a resource group (e.g., VNets, VMs).
- **Parent Resource scope**: unique within a parent entity (e.g., subnets within a VNet).
- **Tenant**: Microsoft Entra Identity objects unique at tenant level.
- Naming rules, allowed characters, and length vary by resource—always refer to the official Microsoft **Naming rules and restrictions for Azure resources** :contentReference[oaicite:8]{index=8}.

---

### Is this every resource with enforced uniqueness?
No. Azure has many services not included here (e.g., IoT Hubs, Data Factories, Databricks, Machine Learning workspaces, etc.) which also have naming and scope requirements. For a full, authoritative list, consult the Microsoft documentation: **[Naming rules and restrictions for Azure resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)** :contentReference[oaicite:9]{index=9}.

All other resource naming requirements are defined in the official Azure documentation and should be referenced directly.


# Azure Global DNS‑Bound PaaS Resources

These Azure services require **globally unique names** due to DNS exposure. The name becomes part of the service's public URL or endpoint. This table lists the most common DNS-bound PaaS resources, with Terraform documentation links and naming rules.

| Service                | Terraform Resource Type                                                                 | DNS Format                                    | Length / Char Constraints                  | Notes |
|------------------------|------------------------------------------------------------------------------------------|-----------------------------------------------|---------------------------------------------|-------|
| Storage Account        | [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | `https://<name>.blob.core.windows.net`       | 3–24 chars, lowercase, alphanumeric only     | Applies to Blob, Table, Queue endpoints |
| Key Vault              | [`azurerm_key_vault`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | `https://<name>.vault.azure.net`             | 3–24 chars, alphanumeric and hyphens, no leading/trailing hyphen | Name must be globally unique |
| App Service            | [`azurerm_app_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service) | `https://<name>.azurewebsites.net`           | 2–60 chars, lowercase letters, numbers, hyphens | Same rules apply to Function Apps |
| Function App           | [`azurerm_function_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) | `https://<name>.azurewebsites.net`           | 2–60 chars, lowercase letters, numbers, hyphens | Function App shares naming rules with App Service |
| Container Registry     | [`azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | `https://<name>.azurecr.io`                  | 5–50 chars, lowercase letters and numbers    | Global DNS name |
| Cosmos DB Account      | [`azurerm_cosmosdb_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | `https://<name>.documents.azure.com`         | 3–44 chars, lowercase, alphanumeric          | Affects account-level API access |
| Search Service         | [`azurerm_search_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service) | `https://<name>.search.windows.net`          | 2–60 chars, lowercase, alphanumeric          | Name used for query and admin endpoints |
| Cognitive Services     | [`azurerm_cognitive_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | `https://<name>.cognitiveservices.azure.com` | 2–64 chars, lowercase letters/numbers        | Applies to all Cognitive APIs |
| Batch Account          | [`azurerm_batch_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_account) | `<name>.<region>.batch.azure.com`            | 3–24 chars, lowercase, alphanumeric          | Used in job scheduling APIs |
| SignalR Service        | [`azurerm_signalr_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/signalr_service) | `https://<name>.service.signalr.net`         | 1–63 chars, lowercase, alphanumeric          | |
| Relay Namespace        | [`azurerm_relay_namespace`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/relay_namespace) | `https://<name>.servicebus.windows.net`      | 6–50 chars, lowercase, alphanumeric          | Shared with Service Bus |
| Event Grid Domain      | [`azurerm_eventgrid_domain`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_domain) | `<name>.<region>-1.eventgrid.azure.net`      | 3–64 chars, lowercase letters/numbers        | |
| Front Door (Classic)   | [`azurerm_frontdoor`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor) | `<name>.azurefd.net`                         | 5–63 chars, lowercase, alphanumeric and hyphens | Used in CDN and WAF routing |

---

## Notes:
- **Globally unique** means the name cannot exist in *any* Azure tenant or subscription.
- DNS-bound services fail Terraform `apply` if the name is already taken.
- For services that are region-specific (e.g., Batch, Event Grid), the DNS still must be globally unique due to shared public endpoint domains.
- Always validate against current [Azure resource naming rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules).



# Azure API Management (‘Management & API’) Resource Naming Reference

These are the core API Management resource types exposed in Terraform, with their naming scope and links to official documentation.

| Resource Type                             | Terraform Resource & Docs                                                                 | Uniqueness Scope | Notes                                                                 |
|-------------------------------------------|--------------------------------------------------------------------------------------------|------------------|------------------------------------------------------------------------|
| API Management Service                    | [`azurerm_api_management`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) | **Global**       | Name must be globally unique; DNS hostnames via custom domain config :contentReference[oaicite:1]{index=1} |
| API Management API                        | [`azurerm_api_management_api`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api) | Service-scoped   | API name unique within the API Management instance :contentReference[oaicite:2]{index=2} |
| API Operation in API Management           | [`azurerm_api_management_api_operation`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_operation) | API-scoped       | Operation ID must be unique within the specific API :contentReference[oaicite:3]{index=3} |
| API Management Group                      | [`azurerm_api_management_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_group) | Service-scoped   | Group ID/name unique per API Management service :contentReference[oaicite:4]{index=4} |
| API Management Custom Domain              | [`azurerm_api_management_custom_domain`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_custom_domain) | Service-scoped   | Custom hostname config (e.g. vanity domains) within the service :contentReference[oaicite:5]{index=5} |

# Azure Networking Resource Naming & Scope Reference

A table of key Azure networking resources, their Terraform types, uniqueness scope, and relevant notes.

| Resource Type                       | Terraform Resource Type & Docs                                                                 | Uniqueness Scope      | Notes |
|------------------------------------|------------------------------------------------------------------------------------------------|------------------------|-------|
| Virtual Network (VNet)             | [`azurerm_virtual_network`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | Resource Group         | Unique within RG :contentReference[oaicite:2]{index=2} |
| Subnet                              | [`azurerm_subnet`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)               | Parent Resource (VNet) | Unique within parent VNet :contentReference[oaicite:3]{index=3} |
| Network Security Group (NSG)       | [`azurerm_network_security_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | Resource Group         | Unique within RG :contentReference[oaicite:4]{index=4} |
| Network Interface (NIC)            | [`azurerm_network_interface`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | Resource Group         | Unique within RG :contentReference[oaicite:5]{index=5} |
| Network Security Rule              | [`azurerm_network_security_rule`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | Parent Resource (NSG)  | Unique per NSG :contentReference[oaicite:6]{index=6} |
| Public IP Address                  | [`azurerm_public_ip`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)         | Resource Group         | Unique within RG (or DNS label globally unique) :contentReference[oaicite:7]{index=7} |
| Load Balancer                      | [`azurerm_lb`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb)                       | Resource Group         | Scoped to RG :contentReference[oaicite:8]{index=8} |
| Application Gateway                | [`azurerm_application_gateway`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | Resource Group         | Scoped to RG :contentReference[oaicite:9]{index=9} |
| Network Profile                    | [`azurerm_network_profile`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_profile) | Resource Group         | Used for DevTest labs or container clusters :contentReference[oaicite:10]{index=10} |
| Network Manager                    | [`azurerm_network_manager`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager)  | Subscription / RG      | Centralized network governance :contentReference[oaicite:11]{index=11} |

# Azure Compute Resource Types — Terraform AzureRM

| Resource Type                         | Terraform Resource Type & Documentation Link                                                                 |
|--------------------------------------|----------------------------------------------------------------------------------------------------------------|
| Availability Set                     | [`azurerm_availability_set`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) |
| Linux / Windows Virtual Machine      | [`azurerm_linux_virtual_machine`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) / [`azurerm_windows_virtual_machine`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) |
| Virtual Machine Scale Set            | [`azurerm_linux_virtual_machine_scale_set`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) / [`azurerm_windows_virtual_machine_scale_set`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine_scale_set) |
| Virtual Machine Extension            | [`azurerm_virtual_machine_extension`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) |
| Azure Compute Gallery                | [`azurerm_shared_image_gallery`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery) |
| Shared Image (Compute Gallery)       | [`azurerm_shared_image`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) |
| Compute Instance (ML workspace)      | [`azurerm_machine_learning_compute_instance`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_compute_instance) |

# Azure Core Infrastructure Resource Naming & Scope Reference

| Service Category     | Resource Type                  | Terraform Resource Type & Docs                                                                 | Naming Scope       | Notes |
|----------------------|--------------------------------|------------------------------------------------------------------------------------------------|---------------------|-------|
| **Core Management**  | Resource Group                 | — (built-in)                                                                                  | **Subscription**    | Name must be unique within the subscription :contentReference[oaicite:1]{index=1} |
| **Networking**       | Virtual Network (VNet)         | [`azurerm_virtual_network`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | **Resource Group** | Unique within RG; cannot change name after creation :contentReference[oaicite:2]{index=2} |
|                      | Subnet                         | [`azurerm_subnet`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)             | **Parent Resource** | Unique within its VNet; cannot be renamed later :contentReference[oaicite:3]{index=3} |
|                      | Network Security Group (NSG)   | [`azurerm_network_security_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | **Resource Group** | Unique within RG |
| **Compute**          | Virtual Machine (VM)           | [`azurerm_linux_virtual_machine`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | **Resource Group** | Unique within RG |
|                      | VM Scale Set                   | [`azurerm_linux_virtual_machine_scale_set`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | **Resource Group** | Unique within RG |
| **Network Interface & Storage** | Network Interface Card (NIC) | [`azurerm_network_interface`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)   | **Resource Group** | Unique within RG |
|                      | Managed Disk                   | [`azurerm_managed_disk`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)           | **Resource Group** | Unique within RG |
| **Load Balancing**   | Load Balancer                  | [`azurerm_lb`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb)                                | **Resource Group** | Scoped to RG |
|                      | Application Gateway (App GW)   | [`azurerm_application_gateway`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | **Resource Group** | Scoped to RG |
| **Identity & Security** | Managed Identity            | [`azurerm_user_assigned_identity`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | **Resource Group** | Unique within RG |
|                      | Role Definition (Custom)       | [`azurerm_role_definition`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition)       | **Subscription / Tenant** | Unique per scope |

---

**Notes on Azure naming scope:**
- **Subscription scope**: resource names must be unique within the subscription.
- **Resource group scope**: names must be unique within their resource group.
- **Parent resource scope**: uniqueness required only within the parent entity (e.g., subnet within a VNet).
- Azure resources, once created, often cannot be renamed and may require removal and recreation to change their names.

For further guidance, refer to the official **Azure Naming Rules and Restrictions** documentation :contentReference[oaicite:4]{index=4}.

---

This table covers the core infrastructure types you'll frequently manage in Terraform and Azure. Let me know if you'd like additional resource types added or examples for naming constraints like character limits or allowed characters.
::contentReference[oaicite:5]{index=5}

# Azure Identity & Security Resource Naming and Scope Reference

| Resource Type / Purpose             | Terraform Resource Type(s) & Docs                                                                 | Uniqueness Scope       | Notes |
|------------------------------------|---------------------------------------------------------------------------------------------------|------------------------|-------|
| Managed Identity (User‑Assigned)   | [`azurerm_user_assigned_identity`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | Resource Group         | Name must be unique within the resource group; maps to a service principal in Entra ID |
| Role Definition (Custom Role)       | [`azurerm_role_definition`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition)          | Subscription or Tenant | Unique within its scope; defines custom RBAC roles |
| App Registration (Azure AD)         | [`azuread_application`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application)                 | Tenant                 | `appId` (GUID) is unique; display name is not enforced unique |
| Service Principal                   | [`azuread_service_principal`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal)   | Tenant                 | Backed by unique `objectId` |
| Azure AD User                       | [`azuread_user`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user)                              | Tenant                 | `userPrincipalName` must be unique in the tenant |
| Azure AD Group                      | [`azuread_group`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group)                            | Tenant                 | Name must be unique within tenant |
| Azure AD Directory Role             | [`azuread_directory_role`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role)          | Tenant                 | Role names must be unique within Entra ID tenant |

# Azure Globally DNS‑Bound PaaS Resources (Globally Unique Names Required)

| Service                  | Terraform Resource Type                                                                 | Example DNS Endpoint                           | Notes |
|--------------------------|-----------------------------------------------------------------------------------------|------------------------------------------------|-------|
| Storage Account          | [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | `https://<name>.blob.core.windows.net`         | Globally unique DNS name required :contentReference[oaicite:2]{index=2} |
| Key Vault                | [`azurerm_key_vault`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | `https://<name>.vault.azure.net`               | Global DNS‑bound endpoint :contentReference[oaicite:3]{index=3} |
| App Service / Function App | [`azurerm_app_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service), [`azurerm_function_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) | `https://<name>.azurewebsites.net`             | Name must be globally unique :contentReference[oaicite:4]{index=4} |
| Container Registry       | [`azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | `https://<name>.azurecr.io`                    | DNS‑bound globally unique name |
| Cosmos DB Account        | [`azurerm_cosmosdb_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | `https://<name>.documents.azure.com`           | DNS used in endpoint; globally unique |
| Search Service           | [`azurerm_search_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service) | `https://<name>.search.windows.net`            | Global unique name ● |
| Cognitive Services       | [`azurerm_cognitive_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | `https://<name>.cognitiveservices.azure.com`   | Globally unique DNS endpoint |
| Batch Account            | [`azurerm_batch_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_account) | `<name>.<region>.batch.azure.com`             | DNS‑bound and globally unique |
| SignalR Service          | [`azurerm_signalr_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/signalr_service) | `https://<name>.service.signalr.net`           | DNS globally unique |
| Relay Namespace          | [`azurerm_relay_namespace`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/relay_namespace) | `https://<name>.servicebus.windows.net`        | Global DNS endpoint |
| Event Grid Domain        | [`azurerm_eventgrid_domain`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_domain) | `<name>.<region>-1.eventgrid.azure.net`        | Global unique DNS name |
| Front Door (Classic)     | [`azurerm_frontdoor`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor) | `<name>.azurefd.net`                          | Globally unique among Front Door instances |

# Entra Identity (Azure AD) Terraform Resources

These are the core Entra ID (Azure AD) resources you can manage via Terraform using the `azuread` provider:

| Resource Type                           | Terraform Resource Type & Docs                                                                 |
|------------------------------------------|----------------------------------------------------------------------------------------------|
| User                                     | [`azuread_user`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user) |
| Group                                    | [`azuread_group`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) |
| Application (App Registration)           | [`azuread_application`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) |
| Service Principal                        | [`azuread_service_principal`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) |
| Role Definitions (Directory Roles)       | [`azuread_directory_role`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) |
| Administrative Unit                      | [`azuread_administrative_unit`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/administrative_unit) |
| Access Package Assignment Policy         | [`azuread_access_package_assignment_policy`](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/access_package_assignment_policy) |

# Azure Global DNS‑Bound PaaS & Analytics Resources

These Azure PaaS and analytics services require **globally unique names**, as the name forms part of a publicly resolvable DNS endpoint. This table lists known services with this requirement, including Terraform resource links where available.

| Service / Category                  | Terraform Resource Type (Link)                                                                              | DNS Endpoint Format                                           | Naming Constraints / Scope                          | Notes |
|------------------------------------|----------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------|-----------------------------------------------------|-------|
| Storage Account                    | [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | `https://<name>.blob.core.windows.net`                       | Global; 3–24 lowercase alphanumeric                  | Covers Blob, Queue, Table, File endpoints :contentReference[oaicite:1]{index=1} |
| Key Vault                          | [`azurerm_key_vault`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)               | `https://<name>.vault.azure.net`                             | Global; DNS-bound, naming rules strict               | :contentReference[oaicite:2]{index=2} |
| App Service / Function App         | [`azurerm_app_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service), [`azurerm_function_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) | `https://<name>.azurewebsites.net`                           | Global; 2–60 lower‑/numeric with hyphens             | :contentReference[oaicite:3]{index=3} |
| Container Registry                 | [`azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | `https://<name>.azurecr.io`                                  | Global; 5–50 lowercase alphanumeric                  | :contentReference[oaicite:4]{index=4} |
| Cosmos DB Account                  | [`azurerm_cosmosdb_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | `https://<name>.documents.azure.com`                         | Global; naming is DNS-bound                          | :contentReference[oaicite:5]{index=5} |
| Search Service                     | [`azurerm_search_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service)         | `https://<name>.search.windows.net`                          | Global; DNS-bound endpoint                           | :contentReference[oaicite:6]{index=6} |
| Cognitive Services Account         | [`azurerm_cognitive_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account)   | `https://<name>.cognitiveservices.azure.com`                 | Global; DNS-bound                                   | :contentReference[oaicite:7]{index=7} |
| Batch Account                      | [`azurerm_batch_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_account)         | `<name>.<region>.batch.azure.com`                            | Global; unique across Azure                          | :contentReference[oaicite:8]{index=8} |
| SignalR Service                    | [`azurerm_signalr_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/signalr_service)     | `https://<name>.service.signalr.net`                         | Global; DNS-bound                                   | :contentReference[oaicite:9]{index=9} |
| Relay Namespace / Service Bus      | [`azurerm_relay_namespace`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/relay_namespace)     | `https://<name>.servicebus.windows.net`                      | Global; DNS endpoint                                 | :contentReference[oaicite:10]{index=10} |
| Event Grid Domain                  | [`azurerm_eventgrid_domain`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_domain)   | `<name>.<region>-1.eventgrid.azure.net`                      | Global; DNS-bound                                   | :contentReference[oaicite:11]{index=11} |
| Front Door (Classic)               | [`azurerm_frontdoor`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor)                 | `<name>.azurefd.net`                                         | Global; DNS subdomain                               | :contentReference[oaicite:12]{index=12} |
| API Management Service (default host) | [`azurerm_api_management`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management)        | `<name>.azure-api.net`                                      | Global; default DNS endpoint                        | :contentReference[oaicite:13]{index=13} |
| Private Link Service Alias         | `azurerm_private_link_service`¹                                                                                  | `Prefix.{GUID}.region.azure.privatelinkservice`             | Global; alias includes GUID making uniqueness        | :contentReference[oaicite:14]{index=14} |

¹ *Terraform resource exists (`azurerm_private_link_service`), but the DNS alias naming is controlled through platform-generated GUID and indicates global uniqueness.*

---

### Are these all such services?
While exhaustive for *widely used* Azure PaaS and analytics services, **new or niche DNS-bound services** may not be included here. Microsoft may introduce new global DNS endpoints over time. Please refer to the official [Azure Naming Rules & Restrictions documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules) for the most current and exhaustive list. :contentReference[oaicite:15]{index=15}
