# 👟 Footwear Webstore CloudOps  

-----

### 🚧 Prerequisites  

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

### 💻 How to Run  

First create the configuration environment:  
```bash
# Build image
$ docker build -t footwear-config-srv .

## Run container
$ docker run --name config-server-1 -it -d -p 22:22 -v "$(pwd):/home/host" --env-file .env footwear-config-srv

# Start terminal session in container
$ docker exec -it config-server-1 /bin/bash
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

To SSH into the EC2 instance, run the following command:  
```bash
# SSH into the EC2 instance
$ ssh -i ../vault/ec2-ssh-key.pem ubuntu@$(terraform output -raw ec2_public_ip)
```

When finished, run the following command to tear down infrastructure:  
```bash
# Change to terraform directory
$ cd /home/host/terraform/

# Destroy provisioned resources
$ terraform destroy
```
