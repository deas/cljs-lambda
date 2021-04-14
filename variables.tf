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

variable "starts" {
  description = "Scheduled start events"
  default = {
    daily = {
      schedule = "cron(00 5 ? * MON-FRI *)"
      event    = <<EOF
{
  "TagKeys": ["start-daily"],
  "DryRun" : false
}
EOF 
    }
  }
}

variable "stops" {
  description = "Scheduled stop events"
  default = {
    daily = {
      schedule = "cron(00 16 * * ? *)"
      event    = <<EOF
{
  "TagKeys": ["stop-daily"],
  "DryRun" : false
}
EOF 
    }
  }
}