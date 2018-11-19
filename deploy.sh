#!/bin/bash

set -e

echo "==> Building and tagging containers..."
CLIENT_PROJECT=squiter/overengineering-fibonacci-client
SERVER_PROJECT=squiter/overengineering-fibonacci-server
WORKER_PROJECT=squiter/overengineering-fibonacci-worker

docker build -t $CLIENT_PROJECT:latest -t $CLIENT_PROJECT:$GIT_SHA -f ./client/Dockerfile ./client
docker build -t $SERVER_PROJECT:latest -t $SERVER_PROJECT:$GIT_SHA -f ./server/Dockerfile ./server
docker build -t $WORKER_PROJECT:latest -t $WORKER_PROJECT:$GIT_SHA -f ./worker/Dockerfile ./worker
echo "==> Containers builded successfully!"

echo "==> Pushing the new containers to Docker Hub..."
docker push $CLIENT_PROJECT:latest
docker push $SERVER_PROJECT:latest
docker push $WORKER_PROJECT:latest
docker push $CLIENT_PROJECT:$GIT_SHA
docker push $SERVER_PROJECT:$GIT_SHA
docker push $WORKER_PROJECT:$GIT_SHA
echo "==> Containers pushed successfully!"

echo "==> Appling kubernetes files..."
kubectl apply -f k8s/
echo "==> Kubernetes files applied successfully!"

echo "==> Forcing update container images in Kubernetes..."
kubectl set image deployments/client-deployment client=$CLIENT_PROJECT:$GIT_SHA
kubectl set image deployments/server-deployment server=$SERVER_PROJECT:$GIT_SHA
kubectl set image deployments/worker-deployment worker=$WORKER_PROJECT:$GIT_SHA
echo "==> Container images updated successfully!"
