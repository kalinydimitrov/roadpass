##################################################################
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

################################################################################

Deploying An Application

Helm

- Create a simple templated helm chart that loads up an nginx server and an appropriate 
ingress. (assume either an nginx or alb controller is just fine) 

- Create a values.yml file that fulfills the values for this helm chart.  

- Show a command that dumps the template generated.  

Github Actions

- Create an example github action that would use Github’s Open ID Connect (OIDC) 
provider as a trusted AWS Identity to deploy the helm chart above into a staging EKS 
cluster. 