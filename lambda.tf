resource "random_pet" "this" {
  length = 2
}

module "cljs_ec2_stop" {
  source                   = "terraform-aws-modules/lambda/aws"
  version                  = "~> 1.44"
  function_name            = "cljs-stop-${random_pet.this.id}"
  publish                  = true
  description              = "🧪 Stopping EC2 Instances - ClojureScript 🥼"
  handler                  = "index.stopInstances"
  runtime                  = "nodejs14.x"
  source_path              = ["${path.module}/dist/lambda"]
  environment_variables    = var.environment
  attach_policy_statements = true
  policy_statements = {
    ec2 = {
      effect    = "Allow",
      actions   = ["ec2:Stop*", "ec2:Describe*"],
      resources = ["*"]
    }
  }
}

// TODO: Appears the same hash confuses terraform module
/* 
module "cljs_ec2_start" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "~> 1.44"
  function_name = "cljs-start-${random_pet.this.id}"
  publish       = true
  description   = "Start EC2 Instances - 🧫 ClojureScript 🧫"
  handler       = "index.startInstances"
  runtime       = "nodejs14.x"
  # create_layer          = true
  source_path           = ["${path.module}/dist/lambda"]
  environment_variables = var.environment

  #  attach_cloudwatch_logs_policy = false
  #  use_existing_cloudwatch_log_group = true
  #  independent_file_timestamps = true
  #  store_on_s3 = true
  #  s3_bucket   = module.s3_bucket.this_s3_bucket_id

  attach_policy_statements = true
  policy_statements = {
    ec2 = {
      effect    = "Allow",
      actions   = ["ec2:Start*", "ec2:Describe*"],
      resources = ["*"]
    },
    #s3 = {
    #  effect    = "Allow",
    #  actions   = ["s3:LIstAllMyBuckets"],
    #  resources = ["arn:aws:s3:::*"]
    #}
  }
 }
*/

resource "aws_cloudwatch_event_rule" "stop_instances" {
  name                = "EC2StopInstancesEvent"
  description         = "EC2 Stop Instances Event"
  schedule_expression = var.stop_schedule
}

resource "aws_cloudwatch_event_target" "stop_instances" {
  rule  = aws_cloudwatch_event_rule.stop_instances.name
  arn   = module.cljs_ec2_stop.this_lambda_function_arn
  input = var.stop_event
}