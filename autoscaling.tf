resource "aws_autoscaling_schedule" "scale_up_day" {
  scheduled_action_name  = "ScaleUpDay"
  min_size               = 4
  max_size               = 4
  desired_capacity       = 4
  recurrence             = "0 8 * * *"
  autoscaling_group_name = aws_elastic_beanstalk_environment.autoscribe_env.name
}

resource "aws_autoscaling_schedule" "scale_down_night" {
  scheduled_action_name  = "ScaleDownNight"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = "0 20 * * *"
  autoscaling_group_name = aws_elastic_beanstalk_environment.autoscribe_env.name
}
