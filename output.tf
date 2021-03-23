# Lambda Function
output "stop_function" {
  description = "The Stop Lambda Function"
  value = {
    "arn" : module.cljs_ec2_stop.this_lambda_function_arn,
    "invoke_arn" : module.cljs_ec2_stop.this_lambda_function_invoke_arn,
    "name" : module.cljs_ec2_stop.this_lambda_function_name,
    "qualified_arn" : module.cljs_ec2_stop.this_lambda_function_qualified_arn
    "version" : module.cljs_ec2_stop.this_lambda_function_version,
    "last_modified" : module.cljs_ec2_stop.this_lambda_function_last_modified,
    "kms_key_arn" : module.cljs_ec2_stop.this_lambda_function_kms_key_arn,
    "source_hash" : module.cljs_ec2_stop.this_lambda_function_source_code_hash,
    "source_code_size" : module.cljs_ec2_stop.this_lambda_function_source_code_size,
    "layer_arn" : module.cljs_ec2_stop.this_lambda_layer_arn,
    "layer_layer_arn" : module.cljs_ec2_stop.this_lambda_layer_layer_arn,
    "layer_created_date" : module.cljs_ec2_stop.this_lambda_layer_created_date,
    "layer_source_code_size" : module.cljs_ec2_stop.this_lambda_layer_source_code_size,
    "layer_version" : module.cljs_ec2_stop.this_lambda_layer_version,
    "role_arn" : module.cljs_ec2_stop.lambda_role_arn,
    "role_name" : module.cljs_ec2_stop.lambda_role_name,
    "cloudwatch_log_group_arn" : module.cljs_ec2_stop.lambda_cloudwatch_log_group_arn,
    "local_filename" : module.cljs_ec2_stop.local_filename
    # "s3_object": module.cljs_ec2_stop.s3_object
  }
}