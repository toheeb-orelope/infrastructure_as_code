variable "vm_os" {
  type = string
  # Default value is set to "windows" for the provisioner script, but it can be overridden to "linux" when applying the Terraform configuration.
  default = "windows"
}