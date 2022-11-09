FROM ubuntu:20.04

# Adding prerequisites
RUN apt-get update && \
    apt-get install -y software-properties-common curl unzip

# Install ansible
RUN add-apt-repository ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y ansible

# Install terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && \
    apt-get install -y terraform

# Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Purge packages
RUN apt-get purge -y curl unzip

WORKDIR /home/host