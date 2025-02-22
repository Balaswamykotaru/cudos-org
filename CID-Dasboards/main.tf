terraform {
  backend "s3" {
    bucket = "terraform-state-cudos-5"
    key    = "global/terraform.tfstate"
    dynamodb_table = "terraform-cudos-5"
    region = "eu-central-1"
  }
}
provider "aws" {
  alias   = "dst"
  region = "eu-central-1"
}
provider "aws" {
  region = "us-east-1"
  alias  = "dst_useast1"
}
# Destination account setup
module "cur_destination" {
  source = "github.com/aws-samples/aws-cudos-framework-deployment//terraform-modules/cur-setup-destination?ref=0.2.39"
  source_account_ids = ["797078318809","611960772844","039014492208"]
  create_cur         = false # Set to true to create an additional CUR in the aggregation account
  # Provider alias for us-east-1 must be passed explicitly (required for CUR setup)
  providers = {
    aws.useast1 = aws.dst_useast1
  }
}
##

provider "aws" {
  region  = "eu-central-1"
  alias   = "src1"
  assume_role {
    role_arn = var.src1_role_arn
  }
}
provider "aws" {
  region  = "us-east-1"
  alias   = "src1_useast1"
  assume_role {
    role_arn = var.src1_role_arn
  }
}
provider "aws" {
  region  = "eu-central-1"
  alias   = "src2"
  assume_role {
    role_arn = var.src2_role_arn
  }
}
provider "aws" {
  region  = "us-east-1"
  alias   = "src2_useast1"
  assume_role {
    role_arn = var.src2_role_arn
  }
 }
# source1 (payer) account
 module "cur_source1" {
  source = "github.com/aws-samples/aws-cudos-framework-deployment//terraform-modules/cur-setup-source?ref=0.2.39"
  destination_bucket_arn = module.cur_destination.cur_bucket_arn
  # Provider alias for us-east-1 must be passed explicitly (required for CUR setup)
  # Optionally, you may pass the default aws provider explicitly as well
  providers = {
    aws         = aws.src1
    aws.useast1 = aws.src1_useast1
  }
}
# source2 (payer) account
 module "cur_source2" {
  source = "github.com/aws-samples/aws-cudos-framework-deployment//terraform-modules/cur-setup-source?ref=0.2.39"
  destination_bucket_arn = module.cur_destination.cur_bucket_arn
  # Provider alias for us-east-1 must be passed explicitly (required for CUR setup)
  # Optionally, you may pass the default aws provider explicitly as well
  providers = {
    aws         = aws.src2
    aws.useast1 = aws.src2_useast1
  }
}

# cid_dashboards 
module "cid_dashboards" {
    source = "github.com/aws-samples/aws-cudos-framework-deployment//terraform-modules/cid-dashboards?ref=0.2.39"
    stack_name      = "Cloud-Intelligence-Dashboards"
    template_bucket = "bucket-cur-test"
  
    stack_parameters = {
      "PrerequisitesQuickSight"            = "yes"
      "PrerequisitesQuickSightPermissions" = "yes"
      "QuickSightUser"                     = "QS-Admin-1/QS-Admin"
      "DeployCUDOSDashboard"               = "yes"
      "DeployCostIntelligenceDashboard"    = "yes"
      "DeployKPIDashboard"                 = "yes"
    }
}
