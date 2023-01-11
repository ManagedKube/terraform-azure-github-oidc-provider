locals {
#   helm_repository     = "https://kubernetes-sigs.github.io/external-dns/"
#   official_chart_name = "external-dns"
  base_name           = "github-actions-oidc"
  ## This should match the name of the service account created by helm chart
  service_account_name = "${local.base_name}-${var.environment_name}"
}

data "azurerm_subscription" "current" {
}

################################################
## Setting up the Azure OIDC Federation
################################################

## Azure AD application that represents the app
resource "azuread_application" "app" {
  display_name = "${local.base_name}-${var.environment_name}"
}

resource "azuread_service_principal" "app" {
  application_id = azuread_application.app.application_id
}

resource "azuread_service_principal_password" "app" {
  service_principal_id = azuread_service_principal.app.id
}

## Azure AD federated identity used to federate kubernetes with Azure AD
resource "azuread_application_federated_identity_credential" "app" {
  application_object_id = azuread_application.app.object_id
  display_name          = "fed-identity-${local.base_name}-${var.environment_name}"
  description           = "The federated identity used to federate K8s with Azure AD with the app service running in k8s ${local.base_name} ${var.environment_name}"
  # Doc for the `audiences` string: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure#adding-the-federated-credentials-to-azure
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com" # var.oidc_k8s_issuer_url
  # Doc for the `subject` string: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#configuring-the-subject-in-your-cloud-provider
  subject               = "repo:intacct/do-infrastructure:pull_request"
    #"repo:octo-org/octo-repo:ref:refs/heads/demo-branch"
    #"system:serviceaccount:${var.k8s_namespace}:${local.service_account_name}"
}

## Role assignment to the application
## Doc: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md#assign-the-rights-for-the-service-principal
## Access permissions
## Error: authorization.RoleAssignmentsClient#Create: Failure
## This most likely means you do not have the correct permissions to perform a role assignment
## Doc: https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal
## This doc shows how to perform a role assignment and talks about checking the permission you have
## Your role might be a global admin but you also need the correct permissions for the Azure Subscription
## This doc shows you how to check what permissions you have for a subscription
## Check: Azure portal -> Subscriptions -> <the subscription in question> -> Settings -> My Permissions -> Go to subscription access control (IAM) -> Check Access -> View My access
## The "contributor" role is not enough.  Per the doc you need: Owner role or User Access Administrator role
##
## The assigned role external-dns needs:
## * https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure-private-dns.md#configure-service-principal-for-managing-the-zone
## * role name: "Private DNS Zone Contributor"
##
## Checking the role assignment:
## * Azure portal -> Azure DNS -> <the zone in question> -> Access Control (IAM) -> Role Assignment
## * The "external-dns-<env>" service principal should be in this list
##
# resource "azurerm_role_assignment" "app_storage_contributor" {
#   ## Scope to for assignment
#   scope                = azuread_application.app.object_id
#   ## The role name (pre-defined built in azure roles)
#   ## Use the "role_definition_id" var to provide it with a custom role definition (see terraform doc for this resource for more informations)
#   role_definition_name = var.role_definition_name
#   ## The principal to assign it to
#   principal_id         = azuread_service_principal.app.id
# }


data "azurerm_subscription" "primary" {
}

resource "azurerm_role_assignment" "this" {
#   name                 = azurerm_role_definition.example.role_definition_id
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Owner" #"Contributor"
  principal_id         = azuread_service_principal.app.id
}

# resource "azurerm_role_definition" "example" {
# #   role_definition_id = "00000000-0000-0000-0000-000000000000"
#   name               = "my-custom-role-definition"
#   scope              = data.azurerm_subscription.primary.id

#   permissions {
#     # See the Terraform resource azurerm_role_definition for more info on
#     # what "actions" are possible
#     actions     = ["*"]
#     not_actions = []
#   }

#   assignable_scopes = [
#     data.azurerm_subscription.primary.id,
#   ]
# }

# resource "azurerm_role_assignment" "example" {
#   name               = azurerm_role_definition.example.role_definition_id
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = azurerm_role_definition.example.role_definition_resource_id
#   principal_id       = azuread_service_principal.app.id
# }