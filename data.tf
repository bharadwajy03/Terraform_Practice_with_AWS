

data "aws_ami" "ubuntu" {

  most_recent = true

  # Canonical Ubuntu AWS account ID.
  owners = ["099720109477"]

  # Find an Ubuntu 24.04 AMI.
  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}