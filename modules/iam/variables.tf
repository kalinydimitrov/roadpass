# modules\iam\variables.tf

variable "GITHUB_USERNAME" {
  description = "GitHub username for OIDC trust relationship"
  type        = string
  default     = "kalinydimitrov"
  
}

variable "GITHUB_REPO_NAME" {
  description = "GitHub repository name for OIDC trust relationship"
  type        = string
  default     = "roadpass" # ???
  
}