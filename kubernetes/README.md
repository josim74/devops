# Kubernetes

## Table of Contents

1. [Introduction](#introduction)
2. [Key Concepts](#key-concepts)
   - [Pods](#pods)
   - [Services](#services)
   - [Deployments](#deployments)
   - [Namespaces](#namespaces)
3. [Installation](#installation)
   - [Using Minikube](#using-minikube)
   - [Using Kubernetes on Cloud (GKE, EKS, AKS)](#using-kubernetes-on-cloud)
4. [Configuration](#configuration)
   - [kubectl Configuration](#kubectl-configuration)
   - [YAML Files](#yaml-files)
5. [Usage](#usage)
   - [Creating a Pod](#creating-a-pod)
   - [Scaling Deployments](#scaling-deployments)
   - [Exposing Services](#exposing-services)
6. [Advanced Topics](#advanced-topics)
   - [Helm Charts](#helm-charts)
   - [StatefulSets](#statefulsets)
   - [Networking in Kubernetes](#networking-in-kubernetes)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)
9. [References](#references)

---

## Introduction

Kubernetes is an open-source platform designed to automate deploying, scaling, and operating containerized applications. It helps manage clusters of containers at scale and provides a robust ecosystem for container orchestration.

## Key Concepts

### Pods
A **Pod** is the smallest deployable unit in Kubernetes, representing a single instance of a running process in your cluster. Pods can contain one or more containers that share storage, network, and specifications.

### Services
A **Service** defines a logical set of Pods and a policy by which to access them. Services enable communication between components within and outside the cluster.

### Deployments
A **Deployment** provides declarative updates for Pods and ReplicaSets, ensuring your application is available and scalable.

### Namespaces
**Namespaces** are used to isolate resources within a cluster, allowing for multiple environments (e.g., dev, staging, prod) to coexist.

## Installation

### Using Minikube
Minikube is a tool that allows you to run Kubernetes locally.

1. Install Minikube:
   ```bash
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   chmod +x minikube-linux-amd64
   sudo mv minikube-linux-amd64 /usr/local/bin/minikube
   ```
2. Start Minikube:
   ```bash
   minikube start
   ```
3. Verify the installation:
   ```bash
   kubectl get nodes
   ```

### Using Kubernetes on Cloud
- **Google Kubernetes Engine (GKE)**: Managed Kubernetes on Google Cloud.
- **Amazon Elastic Kubernetes Service (EKS)**: Managed Kubernetes on AWS.
- **Azure Kubernetes Service (AKS)**: Managed Kubernetes on Azure.

Follow the provider-specific documentation for setup.

## Configuration

### kubectl Configuration
`kubectl` is the command-line tool to interact with Kubernetes clusters.

1. Set up a kubeconfig file:
   ```bash
   kubectl config set-context my-cluster --cluster=my-cluster --namespace=default --user=admin
   ```
2. Test connectivity:
   ```bash
   kubectl cluster-info
   ```

### YAML Files
Kubernetes resources are defined using YAML manifests. Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

Apply the configuration:
```bash
kubectl apply -f my-pod.yaml
```

## Usage

### Creating a Pod
```bash
kubectl run nginx --image=nginx --restart=Never
```

### Scaling Deployments
```bash
kubectl scale deployment my-deployment --replicas=5
```

### Exposing Services
```bash
kubectl expose deployment my-deployment --type=LoadBalancer --port=80
```

## Advanced Topics

### Helm Charts
Helm is a package manager for Kubernetes.

1. Install Helm:
   ```bash
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```
2. Deploy an application using a chart:
   ```bash
   helm install my-release stable/nginx
   ```

### StatefulSets
StatefulSets manage stateful applications with persistent storage.

### Networking in Kubernetes
Learn about **Ingress**, **Network Policies**, and **Service Mesh** for advanced networking.

## Troubleshooting
- Check Pod logs:
  ```bash
  kubectl logs my-pod
  ```
- Debugging issues:
  ```bash
  kubectl describe pod my-pod
  ```

## Best Practices
- Use Namespaces for isolation.
- Use resource limits for Pods.
- Regularly update images to avoid vulnerabilities.
- Monitor your cluster using tools like Prometheus and Grafana.

## References
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Helm Charts](https://helm.sh/)

