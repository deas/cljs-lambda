variable "environment" {
  description = "Environment for lambda function"
  type        = map
  default     = {}
}

variable "provider_role_arn" {
  description = "Provider Role ARN"
  type        = string
  default     = ""
}

variable "stop_schedule" {
  description = "When to stop the instances"
  type        = string
  default     = "cron(00 18 * * ? *)"
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

variable "start_schedule" {
  description = "When to start the instances"
  type        = string
  default     = "cron(00 7 ? * MON-FRI *)"
}

variable "start_event" {
  description = "Start event"
  type        = string
  default     = <<EOF
{
  "TagKeys": ["start-daily"],
  "DryRun" : false
}
EOF
}
