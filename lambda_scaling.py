import boto3
import os

def lambda_handler(event, context):
    region = os.environ['AWS_REGION']
    env_name = os.environ['EB_ENV_NAME']
    
    client = boto3.client('elasticbeanstalk', region_name=region)
    response = client.describe_environments(EnvironmentNames=[env_name])
    
    if not response['Environments']:
        raise Exception(f"No environment found with name {env_name}")

    env_id = response['Environments'][0]['EnvironmentId']
    
    autoscaling_client = boto3.client('autoscaling', region_name=region)
    
    if event['time'] == 'day':
        response = autoscaling_client.update_auto_scaling_group(
            AutoScalingGroupName=env_id,
            MinSize=4,
            MaxSize=4,
            DesiredCapacity=4
        )
    elif event['time'] == 'night':
        response = autoscaling_client.update_auto_scaling_group(
            AutoScalingGroupName=env_id,
            MinSize=1,
            MaxSize=1,
            DesiredCapacity=1
        )
        
    return {
        'statusCode': 200,
        'body': response
    }
