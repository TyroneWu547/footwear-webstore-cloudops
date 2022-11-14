# 👟 Footwear Webstore CloudOps  

# TODO  

have ansible install on instance:  
- docker for container runtime
- production grade kubernetes
  - [k3s](https://github.com/alexellis/k3sup#whats-this-for-) or [microk8s](https://microk8s.io/)
  - min hardware reqs for kubernetes:  
    - 4 GB or more RAM per machine
    - 2 CPUs or more

if have time change 

Will need to research AMI for ec2.  

-----

## 🚧 Prerequisites  

Ensure Git is installed to clone repo...  

Ensure Docker is installed to create configuration environment...  

Ensure AWS account is created to create AWS resources...  

Create `.env` file at top level of repo with your AWS credentials. This information can be found in `~/.aws/config` for the region, and `~/.aws/credentials` for the rest.  

Contents of `.env`:  
```
AWS_ACCESS_KEY_ID=<your-aws-access-key>
AWS_SECRET_ACCESS_KEY=<your-aws-secret-access-key>
AWS_SESSION_TOKEN=<your-aws-session-token>
AWS_DEFAULT_REGION=<your-aws-region>
AWS_DEFAULT_OUTPUT=json
```

Location of where to create `.env`:  
```
footwear-webstore-cloudops/
   +- ...
   +- .env                      <~ over here
```

-----

## 💻 How to Run  

First create your configuration environment:  
```bash
# Build image
$ docker build -t footwear-config-srv .

## Run container
$ docker run --name footwear-config-srv -it -d -p 22:22 -v "$(pwd):/home/host" --env-file .env footwear-config-srv

# Start terminal session in container
$ docker exec -it footwear-config-srv /bin/bash
```

Commands for provisioning the cloud infrastructure:  
```bash
# Change to terraform directory
$ cd /home/host/terraform/

# Download terraform plugins
$ terraform init

# Apply terraform plan
$ terraform apply
```

Commands for setting up kube cluster:  
```bash

```

To SSH into an EC2 instance, run the following command:  
```bash
# SSH into the control node
$ ssh -i ../vault/ec2-ssh-key.pem ubuntu@$(terraform output -raw control_node_ip)

# SSH into the database server
$ ssh -i ../vault/ec2-ssh-key.pem ubuntu@$(terraform output -raw database_server_ip)
```

## 🧹 When Finished...  

Run the following command to tear down the resources:  
```bash
# Change to terraform directory
$ cd /home/host/terraform/

# Destroy provisioned resources
$ terraform destroy

# Exit container
$ exit
```

Commands for deleting container and image:  
```bash
# Stop container
$ docker stop footwear-config-srv

# Delete container
$ docker rm footwear-config-srv

# delete image
$ docker rmi footwear-config-srv
```
