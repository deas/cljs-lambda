resource "random_pet" "this" {
  length = 2
}

/* TODO: WIP
module "cljs_ec2_layer_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 1.44"

  create_layer = true

  layer_name          = "cljs-layer-s3"
  description         = CLJS lambda layer from S3"
  compatible_runtimes = ["nodejs14"]

  source_path = ["${path.module}/dist/lambda"] # "../src/lambda-layer"

  store_on_s3 = true
  s3_bucket   = "cljs-with-lambda-builds"
}
*/

module "cljs_ec2_stop" {
  source                   = "terraform-aws-modules/lambda/aws"
  version                  = "~> 1.44"
  function_name            = "cljs-stop-${random_pet.this.id}"
  publish                  = true
  description              = "🧪 Stop EC2 Instances - ClojureScript 🥼"
  handler                  = "index.stopInstances"
  runtime                  = "nodejs14.x"
  source_path              = ["${path.module}/dist/lambda"]
  hash_extra               = "quickfix-stop"
  environment_variables    = var.environment
  attach_policy_statements = true
  #layers = [
  #  module.cljs_ec2_layer_s3.this_lambda_layer_arn,
  #]
  policy_statements = {
    ec2 = {
      effect    = "Allow",
      actions   = ["ec2:Stop*", "ec2:Describe*"],
      resources = ["*"]
    }
  }
  allowed_triggers = {
    EC2StopInstancesRule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.stop_instances.arn
    }
  }
}

// TODO: Appears the same hash confuses terraform module
module "cljs_ec2_start" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "~> 1.44"
  function_name = "cljs-start-${random_pet.this.id}"
  publish       = true
  description   = "🧫 Start EC2 Instances - ClojureScript 🥼"
  handler       = "index.startInstances"
  runtime       = "nodejs14.x"
  # create_layer          = true
  source_path           = ["${path.module}/dist/lambda"]
  hash_extra            = "quickfix-start"
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
  allowed_triggers = {
    EC2StartInstancesRule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.start_instances.arn
    }
  }

}

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

resource "aws_cloudwatch_event_rule" "start_instances" {
  name                = "EC2StartInstancesEvent"
  description         = "EC2 Start Instances Event"
  schedule_expression = var.start_schedule
}

resource "aws_cloudwatch_event_target" "start_instances" {
  rule  = aws_cloudwatch_event_rule.start_instances.name
  arn   = module.cljs_ec2_start.this_lambda_function_arn
  input = var.start_event
}