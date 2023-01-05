# terraform-azure-github-oidc-provider
Github Action OIDC Setup for Azure

# Creating a service principal with a Federated Credential to use OIDC based authentication
It is essentially following these instructions but via Terraform: https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-federated-credential-to-use-oidc-based-authentication

# Gather info for the Github Actions inputs
These items will be required for the Github Actions inputs:
* https://github.com/marketplace/actions/azure-login#sample-workflow-that-uses-azure-login-action-using-oidc-to-run-az-cli-linux

For the following values:
* client-id
* tenant-id
* subscription-id

## client-id and tenant-id
* After creation of Azure app (after running this Terraform)
* Go to the Azure web console
* Go to "App registration"
* Click on the "All application" tab
* Click on the app that was created.  Default name is: github-actions-oidc-dev

Values: 
* client-id is the "Application (client) ID" value
* tenant-id is the "Directory (tenant) ID" value

## subscription-id
Can be retrieved from the Azure web console by searching "subscription" and selecting
the subscription you are using.

# Viewing resources created in the Azure console

## App Registration
Location: Azure Console -> App Registration -> All applications

# The guide to follow on how to use Azure OIDC Federated auth with Terraform
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc

There are some nuance to it like you have to specify the `use_oidc=true` key/val in the provider and
backend.
