# output "azurerm_role_definition_role_definition_id" {
#   value = azurerm_role_definition.example.role_definition_id
# }

output "azuread_application.app.application_id" {
    value = azuread_application.app.application_id
}

output "azuread_service_principal.app.id" {
    value = azuread_service_principal.app.id
}
