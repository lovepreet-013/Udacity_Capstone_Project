!/usr/bin/env bash

# This tags and uploads an image to Docker Hub

# Step 1:
# This is your Docker ID/path
# dockerpath=<>
dockerpath=lovepreet013/flaskapp

# Step 2
# Run the Docker Hub container with kubernetes
kubectl create deployment kubernetes-flaskapp --image=$dockerpath
kubectl get deployments

# Step 3:
# List kubernetes pods
kubectl get pods
kubectl describe pods

# Step 4:
# Forward the container port to a host
export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo Name of the Pod: $POD_NAME

kubectl port-forward $POD_NAME 8080:80

