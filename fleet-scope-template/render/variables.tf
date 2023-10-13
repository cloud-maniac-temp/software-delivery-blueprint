variable "git_org" {
  description = "GitHub organization."
  type        = string
}

variable "git_user" {
  description = "GitHub user."
  type        = string
}

variable "git_email" {
  description = "GitHub user email."
  type        = string
}

variable "fleet_scope_repo" {
  description = "Fleet scope git repo."
  type        = string
}

variable "namespace" {
  type = string
  description = "Fleet namespace"
}

variable "member_list" {
  type = string
  description = "Members who need access on the fleet"
}

variable "users" {
  type = string
  description = "users on the fleet"
}