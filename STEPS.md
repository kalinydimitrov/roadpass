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
  "nat-04f499e520e824b38",
  "nat-0a6e244a75d4413cb",
]
private_subnets = [
  "subnet-0957abaee35d94a55",
  "subnet-08b0f51c99eb57445",
]
public_subnets = [
  "subnet-08f3a70bffe3b0e94",
  "subnet-058fb6c2a4ee0aef3",
]
ssm_ec2_role_instance_profile_name = "stg-EC2-SSM-Profile"
ssm_instance_profile_name = "stg-EC2-SSM-Profile"
ssm_session_logs_bucket_name = "stg-ssm-session-logs-348737449144"
ssm_test_instance_id = "i-03d2a809b1a8051f1"
vpc_id = "vpc-04689da1ca9acba1e"
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
            "SourceId": "i-03d2a809b1a8051f1",
            "SourceType": "AWS::EC2::Instance"
        }
    ]
}
```
2. Check AWS Console > Systems Manager > Fleet Manager > Managed Instances # << Yes

3. Or use:
```
aws ssm start-session --target i-03d2a809b1a8051f1 --region us-east-1
```

