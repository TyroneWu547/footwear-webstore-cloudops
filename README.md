# ☁️ Footwear Webstore CloudOps  

This cloudops project automates the build and deployment for a provided webapp microservice, called the Footwear Webstore, which creates a self-managed Kubernetes cluster using [microk8s](https://microk8s.io/).  

<p align="center">
<img src="https://github.com/TyroneWu547/footwear-webstore-cloudops/blob/main/docs/kube_cluster_diagram.png">
</p>

**Note:** The Service definitions for Display and Buy uses `NodePort` instead of `ClusterIP` since Locust.io requires direct access to those microservices. In production, these should normally use `ClusterIP`.  

-----

## 🚧 Prerequisites  

Before you begin, ensure you have all of the following:  
- [Docker](https://docs.docker.com/get-docker/)
- AWS Account

**Note:** The instances will utilizing `t3.medium`s, which will cost a couple cents from your AWS account. When finished, make sure to run the **Cleanup** section to delete the resources that been created.  

---  
  
Create `.env` file at top level of repo with your AWS credentials. This information can be found in `~/.aws/config` for the region, and `~/.aws/credentials` for the rest.  

Contents of `.env`:  
```
AWS_ACCESS_KEY_ID=<your-aws-access-key>
AWS_SECRET_ACCESS_KEY=<your-aws-secret-access-key>
AWS_SESSION_TOKEN=<your-aws-session-token>            # <~ if applicable
AWS_DEFAULT_REGION=<your-aws-region>
AWS_DEFAULT_OUTPUT=json
```

Location of where to create `.env`:  
```
footwear-webstore-cloudops/
   +- ...
   +- .env                      <~ over here
```

**Note:** If your are using your AWS Academy Learner Lab Account, make sure that the lab is running (green ball) before outputting the AWS credentials.  

<p align="center">
<img width="450" src="https://github.com/TyroneWu547/footwear-webstore-cloudops/blob/main/docs/aws_academy_lab.png">
</p>

-----

## 💻 How to Run  

First create your configuration environment:  
```bash
# Build image
$ docker build -t footwear-config-srv .

# Create container
$ docker run --name footwear-config-srv -it -d -p 22:22 -p 8089:8089 -v "$(pwd):/home/host" --env-file .env footwear-config-srv

# Start terminal session in container
$ docker exec -it footwear-config-srv /bin/bash
```

Commands for provisioning the cloud infrastructure:  
```bash
# Download terraform plugins
$ terraform -chdir=/home/host/terraform init

# Plan terraform resources
$ terraform -chdir=/home/host/terraform plan

# Apply terraform plan
$ terraform -chdir=/home/host/terraform apply -auto-approve
```

Commands for setting up and deploying the DB Server and Kubernetes Cluster:  
```bash
# First may need to set correct permissions to directory
$ chmod -R 755 /home/host/ansible/

# Change to ansible directory
$ cd /home/host/ansible/

# Run ansible playbook
$ ansible-playbook site.yml
```

🎉 YAY, the application is now deployed!!!! 🎉  

-----  

## 📋 Accessing the Webapp & Dashboard  

The web application should now be reachable through:  
```bash
# URL for the Footwear Webstore applicaiton.
$ echo http://$(terraform -chdir=/home/host/terraform output -raw control_node_ip):30000/products.php

# URL for the microk8s dashbaord
# Note: This URL uses HTTPS instead of HTTP. 
#       Proceed past the "Your connection is not private" page. Don't worry, it's safe. 
$ echo https://$(terraform -chdir=/home/host/terraform output -raw control_node_ip):31000
```

For the dashboard login page, copy and paste the token found in `vault/dashboard_token.txt`:  
```
footwear-webstore-cloudops/
   +- ...
   +- vault/
   |   +- dashboard_token.txt
```

<p align="center">
<img width="450" src="https://github.com/TyroneWu547/footwear-webstore-cloudops/blob/main/docs/dashboard_login.png">
</p>

---  

For Locust.io:  
```bash
# Run locust
$ locust -f /home/host/locust/locustfile.py
```
The UI can be accessed through [http://localhost:8089/](http://localhost:8089/)  
To exit, hit: ctrl + c  

**Note:** The Host field should only contain `http://<IP>`, with no forward slash or port at the end.  

---  

To SSH into an EC2 instance, run the following command:  
```bash
# SSH into the control node
$ ssh -i /home/host/vault/ec2-ssh-key.pem ubuntu@$(terraform -chdir=/home/host/terraform output -raw control_node_ip)

# SSH into the db server
$ ssh -i /home/host/vault/ec2-ssh-key.pem ubuntu@$(terraform -chdir=/home/host/terraform output -raw database_server_ip)
```

The public IPs of the instances can be found in:  
```
footwear-webstore-cloudops/
   +- ...
   +- ansible/
   |   +- inventory/
   |   |   +- inventory
```

-----  

## 🧹 When Finished...  

Run the following command to tear down the resources:  
```bash
# Destroy provisioned resources
$ terraform -chdir=/home/host/terraform destroy -auto-approve

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
