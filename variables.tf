variable "azure_subscription_id" {
  description = "The Azure subscription ID where resources will be created."
  type        = string
  #left empty for privacy, replace with your actual subscription ID
  default     = ""
}

variable "aws_region_1" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = ""
  
}

variable "aws_region_2" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = ""
  
}

variable "azure_region_1" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "East US"
  
}

variable "azure_region_2" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "West US"
}
