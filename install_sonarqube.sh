#!/bin/bash

# Shell script to install Docker and SonarQube on EC2 instance
sudo yum update
sudo yum upgrade -y
sudo dnf install java-17-amazon-corretto-devel -y
sudo yum install git -y
sudo yum install nodejs npm -y
sudo yum install docker -y
sudo usermod -aG docker $USER
sudo newgrp docker
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker
sudo docker pull sonarqube:9.9-community
sudo docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:9.9-community
#where 
#-d: Runs the container in the background.
#--name sonarqube: Sets the name of the container to sonarqube.
#-e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true: Disables the Elasticsearch bootstrap checks to prevent SonarQube from failing to start.
#-p 9000:9000: Maps port 9000 on the EC2 instance to port 9000 in the container.
#sonarqube:9.9-community: Uses the sonarqube:9.9-community image to create the container.
