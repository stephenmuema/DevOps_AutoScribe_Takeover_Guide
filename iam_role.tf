resource "aws_iam_role" "lambda_autoscaling_role" {
  name = "lambda_autoscaling_role"

  assume_role_policy = 
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}

}

resource "aws_iam_role_policy_attachment" "lambda_autoscaling_policy" {
  role       = aws_iam_role.lambda_autoscaling_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_autoscaling_custom_policy" {
  name   = "lambda-autoscaling-custom-policy"
  role   = aws_iam_role.lambda_autoscaling_role.id
  policy = 
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticbeanstalk:DescribeEnvironments",
        "autoscaling:UpdateAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}

}
