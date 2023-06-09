# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

# tflint-ignore: terraform_unused_declarations
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"]
  }

}