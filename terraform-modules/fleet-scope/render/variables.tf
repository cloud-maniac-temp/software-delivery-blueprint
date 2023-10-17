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

variable "git_token" {
  description = "GitHub token."
  type        = string
}

variable "fleet_scope_repo" {
  description = "Fleet scope git repo."
  type        = string
}

variable "fleet_scope" {
  type = string
  description = "Fleet scope, will be the same namespace"
}

variable "member_list" {
  type = list
  description = "Members who need access on the fleet"
}

variable "users" {
  type = string
  description = "users on the fleet"
}