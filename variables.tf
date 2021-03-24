variable "environment" {
  description = "Environment for lambda function"
  type        = map
  default     = {}
}

variable "stop_schedule" {
  description = "When to stop the instances"
  type        = string
  default     = "cron(00 18 * * ? *)"
}

variable "provider_role_arn" {
  description = "Provider Role ARN"
  type        = string
  default     = ""
}

variable "stop_event" {
  description = "Stop event"
  type        = string
  default     = <<EOF
{
  "TagKeys": ["stop-daily"],
  "DryRun" : false
}
EOF
}