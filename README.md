# Terraform AWS Static Site

If you've never used terraform before I would recommend reading this page before you proceed.

[Initial setup Guide & Tutorial](https://hackernoon.com/introduction-to-aws-with-terraform-7a8daf261dc0)

## Prerequisites 

Assuming you have read the article above and have terraform installed and running you will need to setup the following in order to run this script

* An IAM user setup with the AdministratorAccess policy
* A domain in Route 53 with an accompanying hosted zone
* A certificated created in the AWS certificate manager 

## Configuration

In the root of the project create a file called **terraform.tfvars** containing the following with the values filled in.

```
aws_access_key=""
aws_secret_key=""
aws_cert_arn=""
hosted_zone_id=""
aws_aliases=["",""]
```

## Running

It is then quite simple you can test your plan by running something like this

```
terraform plan;
```

and then apply it to your infrastructure like this

```
terraform apply;
```

Don't fear if you make a mistake you can always destroy the infrastructure you created

```
terraform destroy;
```
