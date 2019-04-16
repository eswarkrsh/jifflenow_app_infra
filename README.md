# jifflenow_app_infra
- Launches a web server, installs nginx, creates an ELB for instance. It also creates security groups for the ELB and EC2 instance

- The Amazon Web Services (AWS) provider is used to interact with the many resources supported by AWS. The provider needs to be configured with the proper credentials before it can be used - https://www.terraform.io/docs/providers/aws/index.html

- SSH Key Pair to be generated

- Run: terraform apply -var 'key_name=KEY_NAME'

- EC2 userdata to install nginx, and the ELB DNS Name oputpts the nginx page

# Containers using docker Swarm

- Build image, Tag the image version and push the image to public or privare registry

- Lauch Docker Swarm service on all the machines having one a leader and other join as followers

- Run the built app image and launch as service (docker service command)

- Replicas of service will be load balanced between the EC2 machines

