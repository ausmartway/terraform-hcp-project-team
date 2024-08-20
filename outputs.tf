output "project_id" {
  value = hcp_project.consumer.resource_id
  description = "tfe project"
}

output "project_name" {
  value = hcp_project.consumer.name
  description = "tfe project"
}


output "project_map" {
  value = tomap({"${hcp_project.consumer.name}" = {"project_id"=hcp_project.consumer.resource_id,"bu"=var.business_unit} })
  description = "tfe project map"
}

output "bu" {
  value = var.business_unit
  description = "tfe project"
}

output "team" {
  value = hcp_group.this
  description = "tfe teams pre-defined rbac"
}

output "team_custom" {
  value = hcp_group.custom
  description = "tfe teams custom rbac"
}

output "enable_oidc" {
  value = var.enable_oidc
  description = "enable oidc"
}