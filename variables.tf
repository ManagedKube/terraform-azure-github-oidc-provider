variable "environment_name" {
  type = string
  default = "dev"
  description = "An arbitrary environment name"
}

variable "oidc_k8s_issuer_url" {
  type        = string
  default     = ""
  description = "The OIDC k8s issuer url.  If using the kubernetes-ops/azure creation it would be in the AKS output."
}

variable "role_definition_name" {
  type        = string
  default     = "Contributor"
  description = "The pre-defined azure role to use; Contributor, Owner, etc"
}

variable "azure_resource_group_name" {
  type        = string
  default     = null
  description = "The Azure resource group"
}
