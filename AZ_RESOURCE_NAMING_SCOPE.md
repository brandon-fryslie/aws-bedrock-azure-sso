# Azure Resource Naming Scoping Requirements

This document lists the resource

⸻


# Azure DNS‑Bound PaaS & Analytics Resources — Grouped by Uniqueness Scope

This document groups Azure PaaS and analytics services by the **scope within which their names must be unique**. Most DNS-bound services are **globally scoped**, but some services embed GUIDs or regional prefixes, relaxing the naming constraint.

---

## 🔒 Globally Unique Name Required

These services expose DNS endpoints directly under Microsoft-owned domains and therefore require names unique across *all Azure tenants and subscriptions*.

| Service                         | Terraform Resource Type                                                                 | DNS Format                                       | Constraints                                     |
|---------------------------------|------------------------------------------------------------------------------------------|--------------------------------------------------|-------------------------------------------------|
| Storage Account                 | [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | `<name>.blob.core.windows.net`                  | 3–24 chars, lowercase alphanumeric              |
| Key Vault                       | [`azurerm_key_vault`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)               | `<name>.vault.azure.net`                        | 3–24 chars, alphanumeric, no hyphen edges       |
| App Service / Function App      | [`azurerm_app_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service)<br>[`azurerm_function_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) | `<name>.azurewebsites.net`                      | 2–60 chars, lowercase, alphanumeric, hyphens    |
| Container Registry              | [`azurerm_container_registry`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | `<name>.azurecr.io`                             | 5–50 chars, lowercase alphanumeric              |
| Cosmos DB Account               | [`azurerm_cosmosdb_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | `<name>.documents.azure.com`                   | 3–44 chars, lowercase alphanumeric              |
| Search Service                  | [`azurerm_search_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service)         | `<name>.search.windows.net`                     | 2–60 chars, lowercase alphanumeric              |
| Cognitive Services Account      | [`azurerm_cognitive_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account)   | `<name>.cognitiveservices.azure.com`           | 2–64 chars, lowercase alphanumeric              |
| Batch Account                   | [`azurerm_batch_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_account)         | `<name>.<region>.batch.azure.com`              | 3–24 chars, lowercase alphanumeric              |
| SignalR Service                 | [`azurerm_signalr_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/signalr_service)     | `<name>.service.signalr.net`                   | 1–63 chars, lowercase alphanumeric              |
| Relay Namespace / Service Bus   | [`azurerm_relay_namespace`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/relay_namespace)     | `<name>.servicebus.windows.net`                | 6–50 chars, lowercase alphanumeric              |
| Event Grid Domain               | [`azurerm_eventgrid_domain`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_domain)   | `<name>.<region>-1.eventgrid.azure.net`        | 3–64 chars, lowercase alphanumeric              |
| Front Door (Classic)           | [`azurerm_frontdoor`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor)                 | `<name>.azurefd.net`                           | 5–63 chars, lowercase alphanumeric, hyphens     |
| API Management (Default Host)  | [`azurerm_api_management`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management)        | `<name>.azure-api.net`                         | 1–50 chars, lowercase alphanumeric              |

---

## 🌀 Regionally Unique (Embedded DNS Suffix Handles Conflict)

These services generate DNS endpoints that **embed a region or GUID**, making full global uniqueness unnecessary—but naming is still scoped to avoid collisions at provisioning time.

| Service                    | Terraform Resource Type                                                                 | DNS Format                                           | Constraints                                        |
|----------------------------|------------------------------------------------------------------------------------------|------------------------------------------------------|----------------------------------------------------|
| Private Link Service Alias | [`azurerm_private_link_service`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_link_service) | `prefix.{GUID}.{region}.azure.privatelinkservice`   | DNS uses a generated alias with embedded GUID      |

---

## ⚠️ Important Notes

- **Global scope** means a name like `myapp` will conflict with *any* existing app using the same name in another tenant.
- Terraform `apply` will fail if the name is taken.
- Some services not listed here may also have global DNS constraints. Always validate via:  
  [Azure Resource Name Rules (official docs)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)

---

# Azure Resources Whose **Names Must Be Unique *within a Resource Group***

Most Azure resource types inherit the default rule: **their `name` must be unique only inside the containing Resource Group** (RG).  They do **not** collide across different RGs—even in the same subscription—unless specifically noted otherwise (e.g., globally DNS-bound services).

The table below lists the commonly-used resource types that follow this **RG-scoped uniqueness** rule.  Terraform resource types link directly to the Registry docs.

| Service Category | Azure Resource | Terraform Resource Type | Name Scope | Key Naming Notes |
|------------------|----------------|-------------------------|------------|------------------|
| **Compute** | Virtual Machine | [`azurerm_linux_virtual_machine`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)<br>[`azurerm_windows_virtual_machine`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | Resource Group | 1-15 chars (Win) / 1-64 (Linux); letters, numbers, `-` |
| | VM Scale Set | [`azurerm_linux_virtual_machine_scale_set`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | Resource Group | ≤ 260 chars; letters/numbers/`-` |
| | Availability Set | [`azurerm_availability_set`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | Resource Group | ≤ 80 chars |
| | Managed Disk | [`azurerm_managed_disk`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | Resource Group | ≤ 80 chars; letters, numbers, `-_` |
| | Image | [`azurerm_image`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/image) | Resource Group | ≤ 80 chars |
| | Snapshot | [`azurerm_snapshot`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/snapshot) | Resource Group | ≤ 80 chars |
| **Networking** | Virtual Network (VNet) | [`azurerm_virtual_network`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | Resource Group | ≤ 64 chars; letters, numbers, `-_` |
| | Network Security Group (NSG) | [`azurerm_network_security_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | Resource Group | ≤ 80 chars |
| | Network Interface (NIC) | [`azurerm_network_interface`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | Resource Group | ≤ 80 chars |
| | Public IP (resource **name**)† | [`azurerm_public_ip`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | Resource Group | Name unique in RG; DNS label **globally** unique |
| | Load Balancer | [`azurerm_lb`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | Resource Group | ≤ 80 chars |
| | Application Gateway | [`azurerm_application_gateway`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | Resource Group | ≤ 80 chars |
| | NAT Gateway | [`azurerm_nat_gateway`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | Resource Group | ≤ 80 chars |
| | Route Table | [`azurerm_route_table`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | Resource Group | ≤ 80 chars |
| | Private DNS Zone | [`azurerm_private_dns_zone`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | **Global** by DNS name (zone) | Zone’s FQDN must be unique globally (DNS rule) |
| **Identity / Security** | User-Assigned Managed Identity | [`azurerm_user_assigned_identity`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | Resource Group | ≤ 128 chars |
| **Monitoring & Ops** | Log Analytics Workspace | [`azurerm_log_analytics_workspace`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | Resource Group | ≤ 63 chars; letters, numbers, `-`, cannot start/end with `-` |
| | Automation Account | [`azurerm_automation_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | Resource Group | ≤ 50 chars |
| **Databases & Cache** | SQL Server | [`azurerm_sql_server`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_server) | Resource Group | 1-128 chars; letters/numbers/hyphens; must start with letter |
| | SQL Database | [`azurerm_sql_database`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_database) | Resource Group | ≤ 128 chars |
| | PostgreSQL Flexible Server | [`azurerm_postgresql_flexible_server`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | Resource Group | 3-63 lowercase letters/numbers |  
| | MySQL Flexible Server | [`azurerm_mysql_flexible_server`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server) | Resource Group | 3-63 lowercase letters/numbers |
| | Redis Cache | [`azurerm_redis_cache`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | Resource Group | 6-63 chars; lowercase letters/numbers |
| **Integration** | Logic App Standard | [`azurerm_logic_app_standard`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_standard) | Resource Group | ≤ 80 chars |
| **Containers & Kubernetes** | Container Group (ACI) | [`azurerm_container_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | Resource Group | ≤ 63 chars |
| | Kubernetes Cluster (AKS) | [`azurerm_kubernetes_cluster`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | Resource Group | ≤ 63 chars; lowercase letters/numbers |
| **App Services (plans & slots)** | App Service Plan | [`azurerm_app_service_plan`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan) | Resource Group | 1-40 chars |
| | App Service Deployment Slot | [`azurerm_app_service_slot`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_slot) | Parent (Web App) | Unique within its App Service |

† *Public IP*: the **resource object’s `name`** is RG-scoped; its **DNS label** (optional) must be globally unique under `*.region.cloudapp.azure.com`.

---

### Quick Rule-of-Thumb

> **If a resource is *not* globally DNS-bound and *not* one of a handful of subscription- or tenant-scoped resources (e.g., Resource Group itself, custom Role Definitions, Entra objects), its name can be assumed unique only within the containing Resource Group.**

For authoritative, always-up-to-date details, refer to the Microsoft documentation: **“Naming rules and restrictions for Azure resources.”**
