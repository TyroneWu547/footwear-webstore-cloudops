#!/bin/sh

# Make sure to chmod +x this file

# Create .env file
touch .env

# Copy credentials to .env as environment variables
echo "AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials | grep -o 'aws_access_key_id.*' | cut -f2- -d'=' | xargs)" >> .env
echo "AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials | grep -o 'aws_secret_access_key.*' | cut -f2- -d'=' | xargs)" >> .env
echo "AWS_SESSION_TOKEN=$(cat ~/.aws/credentials | grep -o 'aws_session_token.*' | cut -f2- -d'=' | xargs)" >> .env
echo "AWS_DEFAULT_REGION=$(cat ~/.aws/config | grep -o 'region.*' | cut -f2- -d'=' | xargs)" >> .env
echo "AWS_DEFAULT_OUTPUT=json" >> .env
