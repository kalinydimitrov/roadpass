# Initialize a new Git repository
git init

# Add all existing files
git add .

# Commit your initial version
git commit -m "Initial commit"

# Create and switch to staging branch
git branch -M staging

# Add your GitHub remote
git remote add origin https://github.com/kalinydimitrov/roadpass.git

# Verify remote was added
git remote -v

# Push to GitHub (main branch)

git push -u origin staging

# Run Terraform from inside the environment folder:

cd environments/staging

terraform init

terraform fmt

terraform validate

terraform plan

terraform apply

# checkov security scan:

In project root (/mnt/d/Projects/ThorIndustries/Roadpass) execute: 
```
checkov -d .
```

# VPC module Outputs:
```
nat_gateways = [
  "nat-0aea95c3fa36a2ed0",
  "nat-0a96ceb9d22761f93",
]
private_subnets = [
  "subnet-05388083d2642f187",
  "subnet-09ee5d049f147d899",
]
public_subnets = [
  "subnet-059ff38890f95e7ac",
  "subnet-03d66a1d5b2ecf97f",
]
ssm_ec2_role_instance_profile_name = "stg-EC2-SSM-Profile"
ssm_instance_profile_name = "stg-EC2-SSM-Profile"
ssm_session_logs_bucket_name = "stg-ssm-session-logs-348737449144"
ssm_test_instance_id = "i-0ffb6377067ca91c2"
vpc_id = "vpc-03c34aa0c52de9d00"
```

# Steps to validate:

1. Confirm instance is managed by SSM
```
aws ssm describe-instance-information --region us-east-1
```
output:
```
{
    "InstanceInformationList": [
        {
            "InstanceId": "i-03d2a809b1a8051f1",
            "PingStatus": "Online",
            "LastPingDateTime": "2025-10-21T13:57:39.426000+03:00",
            "AgentVersion": "3.3.3050.0",
            "IsLatestVersion": false,
            "PlatformType": "Linux",
            "PlatformName": "Amazon Linux",
            "PlatformVersion": "2023",
            "ResourceType": "EC2Instance",
            "IPAddress": "172.16.45.226",
            "ComputerName": "ip-172-16-45-226.ec2.internal",
            "SourceId": "i-0ffb6377067ca91c2",
            "SourceType": "AWS::EC2::Instance"
        }
    ]
}
```
2. Go to Systems Manager → Session Manager → Preferences → Edit,
then choose:
```
S3 bucket: stg-ssm-session-logs-348737449144

Key prefix: logs/
```
That writes an internal JSON configuration in the SSM control plane.

3. Start session to EC2 instance:

```
aws ssm start-session \
  --target i-0ffb6377067ca91c2 \
  --document-name AWS-StartInteractiveCommand \
  --parameters command="bash" \
  --region us-east-1
```

execute "whoami" or "ls"

4. In AWS Console open "stg-ssm-session-logs-348737449144" bucket and check for logs

#################################################
```
aws cloudformation validate-template --template-body "file://eks-cluster-existing-vpc.yaml"
```

```
aws cloudformation create-stack \
  --stack-name stg-eks-cluster \
  --template-body file://eks-cluster-existing-vpc.yaml \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --region us-east-1 \
  --parameters \
    ParameterKey=ClusterName,ParameterValue=stg-eks-cluster \
    ParameterKey=VpcId,ParameterValue=vpc-03c34aa0c52de9d00 \
    ParameterKey=PrivateSubnet1Id,ParameterValue=subnet-05388083d2642f187 \
    ParameterKey=PrivateSubnet2Id,ParameterValue=subnet-09ee5d049f147d899
```

Expected outpot"
```
{
    "StackId": "arn:aws:cloudformation:us-east-1:348737449144:stack/stg-eks-cluster/f3032a80-ae90-11f0-89dd-12a545630827"
}
```

```
aws cloudformation delete-stack \
  --stack-name stg-eks-cluster \
  --region us-east-1
```
