resource "aws_elastic_beanstalk_application" "autoscribe_app" {
  name        = "autoscribe-app"
  description = "Auto Scribe application deployed using Elastic Beanstalk"
}

resource "aws_elastic_beanstalk_environment" "autoscribe_env" {
  name                = "autoscribe-env"
  application         = aws_elastic_beanstalk_application.autoscribe_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.7 running Python 3.8"

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "WSGIPath"
    value     = "autoscribe.wsgi:application"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "MinInstancesInService"
    value     = "1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "MaxInstancesInService"
    value     = "4"
  }
}
