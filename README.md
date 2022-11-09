# 👟 Footwear Webstore CloudOps  

### 🚧 Prerequisites  

git

Docker  

AWS Account  

Create `.env` file at root level of repo:  
```
AWS_ACCESS_KEY_ID=<your-aws-access-key>
AWS_SECRET_ACCESS_KEY=<your-aws-secret-access-key>
AWS_SESSION_TOKEN=<your-aws-session-token>
AWS_DEFAULT_REGION=<your-aws-region>
AWS_DEFAULT_OUTPUT=json
```

or

If using AWS Academy Lab, run these commands to generate the `.env` file for you:  
```bash
# Make shell script executable
$ chmod +x generate-aws-env.sh

# Run shell script to generate .env
$ ./generate-aws-env.sh
```

### 💻 How to Run  

```bash
# Clone repo and change into the repo
$ git clone https://github.com/TyroneWu547/footwear-webstore-cloudops.git
$ cd footwear-webstore-cloudops

# Build image
$ docker build -t footwear-config-srv .

## Run container
$ docker run --name config-server-1 -it -d -p 22:22 -v "$(pwd):/home/host" --env-file .env footwear-config-srv

# Start terminal session in container
docker exec -it config-server-1 /bin/bash
```

Once inside the container:  
```bash

```
