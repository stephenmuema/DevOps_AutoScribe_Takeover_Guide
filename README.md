**DevOps Terraform Training on old Prod Environment from 2023**

Due to requests from peers in cybersecurity, I have open-sourced this prod environment created with Terraform in 2022 for my startup which a company in Asia later acquired. They shifted to Google Cloud, so I'm revealing the README file and terraform configurations I shared with them during the transfer phase. I am neither an expert nor a tutor, but ni God tu 😁. Good luck!!

Here are the testing steps to run the entire deployment process, including setting up Terraform, configuring GitLab CI/CD, and deploying the Django application to AWS Elastic Beanstalk with auto-scaling and WAF configurations.:

### Step 1: Prerequisites

1. **Install Terraform**: Ensure Terraform is installed on your local machine.
   ```bash
   wget https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_amd64.zip
   unzip terraform_1.5.3_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   terraform --version
   ```

2. **AWS CLI**: Install and configure AWS CLI with your AWS credentials.
   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   aws configure
   ```

3. **GitLab Runner**: Ensure you have a GitLab Runner set up for your project.

### Step 2: Set Up Terraform

1. **Create a Project Directory**: Create a directory for your Terraform files.
   ```bash
   mkdir autoscribe-terraform
   cd autoscribe-terraform
   ```

2. **Create Terraform Configuration Files**: Create the necessary Terraform files (`provider.tf`, `main.tf`, `s3.tf`, `waf.tf`, `autoscaling.tf`, `iam_role.tf`, `cloudwatch_events.tf`).

3. **Initialize Terraform**: Initialize Terraform in your project directory.
   ```bash
   terraform init
   ```

### Step 3: Configure Lambda Function

1. **Create Lambda Function**: Create a directory for the Lambda function, write the `lambda_scaling.py` script, and package it.
   ```bash
   mkdir lambda
   cd lambda
   nano lambda_scaling.py
   zip lambda_scaling.zip lambda_scaling.py
   ```

2. **Upload Lambda Package to S3**: Upload the `lambda_scaling.zip` to your S3 bucket.
   ```bash
   aws s3 cp lambda_scaling.zip s3://autoscribe-data-lake/lambda_scaling.zip
   ```

### Step 4: Configure GitLab CI/CD

1. **Add `.gitlab-ci.yml`**: Add the CI/CD configuration file to your project repository.
   ```yaml
   stages:
     - test
     - package
     - deploy

   variables:
     AWS_REGION: "us-west-2"
     S3_BUCKET_NAME: "autoscribe-data-lake"
     EB_APP_NAME: "autoscribe-app"
     EB_ENV_NAME: "autoscribe-env"

   before_script:
     - pip install -r requirements.txt
     - apt-get update && apt-get install -y zip unzip
     - curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     - unzip awscliv2.zip
     - ./aws/install

   test:
     stage: test
     script:
       - python manage.py test

   package:
     stage: package
     script:
       - zip -r autoscribe.zip autoscribe
       - aws s3 cp autoscribe.zip s3://$S3_BUCKET_NAME/autoscribe.zip
       - zip lambda_scaling.zip lambda_scaling.py
     artifacts:
       paths:
         - autoscribe.zip
         - lambda_scaling.zip

   deploy:
     stage: deploy
     script:
       - terraform init
       - terraform plan
       - terraform apply -auto-approve
       - aws elasticbeanstalk create-application-version --application-name $EB_APP_NAME --version-label v1 --source-bundle S3Bucket=$S3_BUCKET_NAME,S3Key=autoscribe.zip
       - aws elasticbeanstalk update-environment --environment-name $EB_ENV_NAME --version-label v1
   ```

2. **Set Environment Variables in GitLab**: Go to your project settings in GitLab and set the necessary environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `S3_BUCKET_NAME`
   - `EB_APP_NAME`
   - `EB_ENV_NAME`

### Step 5: Deploy with Terraform

1. **Run Terraform Apply**: In your local machine, navigate to your Terraform project directory and apply the configuration.
   ```bash
   terraform apply -auto-approve
   ```

2. **Check AWS Resources**: Verify that the Elastic Beanstalk application, environment, S3 bucket, WAF, auto-scaling configurations, and Lambda functions are correctly set up in your AWS account.

### Step 6: Set Up GitLab CI/CD Pipeline

1. **Push to GitLab**: Commit and push your changes to GitLab to trigger the CI/CD pipeline.
   ```bash
   git add .
   git commit -m "Initial commit with Terraform and GitLab CI/CD configuration"
   git push origin main
   ```

2. **Monitor Pipeline**: Monitor the pipeline execution in GitLab. The stages should run in the following order:
   - Test: Run tests for the Django application.
   - Package: Package the application and upload artifacts to S3.
   - Deploy: Deploy the application to Elastic Beanstalk using Terraform.

### Step 7: Verify Deployment

1. **Access Elastic Beanstalk Environment**: Once the deployment is complete, access the Elastic Beanstalk environment URL to verify that the Django application is running.

2. **Check Auto-Scaling and WAF**: Verify the auto-scaling settings and WAF configurations in the AWS Management Console to ensure they are set up correctly.

### Step 8: Monitor and Maintain

1. **CloudWatch Monitoring**: Use AWS CloudWatch to monitor the performance and logs of your Elastic Beanstalk environment, Lambda functions, and other AWS resources.

2. **Regular Updates**: Regularly update your Terraform scripts, CI/CD pipeline, and application code to incorporate security patches and new features.

3. **Audit and Review**: Note that speech data across different regions/sectors is subjected to various regulations eg HIPAA for health.
