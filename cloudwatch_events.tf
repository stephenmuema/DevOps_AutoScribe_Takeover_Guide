resource "aws_cloudwatch_event_rule" "scale_up_day" {
  name                = "scale-up-day"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "scale_down_night" {
  name                = "scale-down-night"
  schedule_expression = "cron(0 20 * * ? *)"
}

resource "aws_lambda_function" "autoscaling_lambda" {
  filename         = "lambda_scaling.zip"
  function_name    = "autoscaling_lambda"
  role             = aws_iam_role.lambda_autoscaling_role.arn
  handler          = "lambda_scaling.lambda_handler"
  source_code_hash = filebase64sha256("lambda_scaling.zip")
  runtime          = "python3.8"
  environment {
    variables = {
      AWS_REGION = "us-west-2"
      EB_ENV_NAME = "autoscribe-env"
    }
  }
}

resource "aws_cloudwatch_event_target" "target_scale_up_day" {
  rule      = aws_cloudwatch_event_rule.scale_up_day.name
  target_id = "lambda_scale_up_day"
  arn       = aws_lambda_function.autoscaling_lambda.arn
  input     = jsonencode({
    "time": "day"
  })
}

resource "aws_cloudwatch_event_target" "target_scale_down_night" {
  rule      = aws_cloudwatch_event_rule.scale_down_night.name
  target_id = "lambda_scale_down_night"
  arn       = aws_lambda_function.autoscaling_lambda.arn
  input     = jsonencode({
    "time": "night"
  })
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda_scale_up_day" {
  statement_id  = "AllowExecutionFromCloudWatchScaleUpDay"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoscaling_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scale_up_day.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda_scale_down_night" {
  statement_id  = "AllowExecutionFromCloudWatchScaleDownNight"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoscaling_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scale_down_night.arn
}
