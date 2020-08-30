#!/usr/bin/env bash
# Create an EKS Cluster and download the kubeconfig file
echo "Creating an EKS Cluster ..."
eksctl create cluster \
--name dev \
--version 1.16 \
--region us-east-1 \
--nodegroup-name standard-workers \
--node-type t3.micro \
--nodes 3 \
--nodes-min 1 \
--nodes-max 4 \
--asg-access

echo "Downloading Kubeconfig Files"
aws eks update-kubeconfig --name dev --region us-east-1
