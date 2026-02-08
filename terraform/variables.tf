variable "aws_region" {
  description = "Région AWS"
  default     = "eu-west-3" # Paris
}

variable "docker_image" {
  description = "maxwellfaraday/jenkins-training-app"
  type        = string
}

variable "docker_tag" {
  description = "1.0"
  type        = string
  default     = "latest"
}