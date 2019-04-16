# jifflenow_app_infra
- Launches a web server, installs nginx, creates an ELB for instance. It also creates security groups for the ELB and EC2 instance

- The Amazon Web Services (AWS) provider is used to interact with the many resources supported by AWS. The provider needs to be configured with the proper credentials before it can be used - https://www.terraform.io/docs/providers/aws/index.html

- SSH Key Pair to be generated

- Run: terraform apply -var 'key_name=YOUR_KEY_NAME'

- EC2 userdata to install nginx, and the ELB DNS Name oputpts the nginx page
