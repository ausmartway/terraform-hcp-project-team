#Consumer BU Project
locals {
  
}

resource "hcp_project" "consumer" {
  name         = var.project_name
  description  = var.project_description
}


resource "tfe_project_variable_set" "project" {
  count           = var.create_variable_set ? 1 : 0
  variable_set_id = module.terraform-tfe-variable-sets[0].variable_set[0].id
  project_id      = hcp_project.consumer.resource_id
}

module "terraform-tfe-variable-sets" {
  source = "github.com/hashi-demo-lab/terraform-tfe-variable-sets?ref=v0.4.1"
  count  = var.create_variable_set ? 1 : 0

  organization             = var.organization_name
  create_variable_set      = var.create_variable_set
  variables                = try(var.varset.variables, {})
  variable_set_name        = try(var.varset.variable_set_name, "")
  variable_set_description = try(var.varset.variable_set_description, "")
  tags                     = try(var.varset.tags, [])
  global                   = try(var.varset.global, false)
}

resource "hcp_group" "this" {
  for_each = var.team_project_access
  display_name         = "${var.business_unit}_${each.key}"
  # organization = var.organization_name
  # sso_team_id  = try(each.value.team.sso_team_id, null)
}

resource "hcp_group" "custom" {
  for_each = var.custom_team_project_access
  display_name         = "${var.business_unit}_${each.key}"
  # organization = var.organization_name
  # sso_team_id  = try(each.value.team.sso_team_id, null)
}

resource "tfe_team_project_access" "default" {
  for_each = var.team_project_access

  access     = each.value.team.access
  team_id    = hcp_group.this[each.key].id
  project_id = hcp_project.consumer.resource_id
}

resource "tfe_team_project_access" "custom" {
  for_each = var.custom_team_project_access

  access     = each.value.team.access
  team_id    = hcp_group.custom[each.key].id
  project_id = hcp_project.consumer.resource_id

  project_access {
    settings = try(each.value.project_access.settings, "read")
    teams    = try(each.value.project_access.teams, "none")
  }

  workspace_access {
    runs           = try(each.value.workspace_access.runs, "read")
    sentinel_mocks = try(each.value.workspace_access.sentinel_mocks, "none")
    state_versions = try(each.value.workspace_access.state_versions, "none")

    variables = try(each.value.workspace_access.variables, "none")
    create    = try(each.value.workspace_access.create, false)
    locking   = try(each.value.workspace_access.locking, false)
    delete    = try(each.value.workspace_access.delete, false)
    move      = try(each.value.workspace_access.move, false)
    run_tasks = try(each.value.workspace_access.run_tasks, false)
  }
}

# bu-control team project  access
resource "tfe_team_project_access" "bu-control" {
  access     = var.bu_control_admins_access # to add var for this
  team_id    = var.bu_control_admins_id
  project_id = hcp_project.consumer.resource_id
}
 
