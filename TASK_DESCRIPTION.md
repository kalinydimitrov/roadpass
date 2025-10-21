AWS VPC Exercise

You have been assigned a project to create a new terraform module for creating a staging VPC 
in AWS. The following requirements have been given to you.  

- The network supernet of 172.16.0.0/16 

- The VPC should provide an endpoint for AWS Systems Manager (SSM), internally.  

- The VPC should provide an internal endpoint for S3.
  
- The VPC should have two different availability zones, with two private subnets and two 
public subnets for each availability zone.  

- The VPC should contain appropriate routing tables. 

- The VPC should include appropriate NAT gateways and an internet gateway.  

Create module code to fulfill this request utilizing terragrunt/terraform. Show how you would use 
this module code to bring up the given architecture. 