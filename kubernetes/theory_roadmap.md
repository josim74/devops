# 📘 Phase 1: Kubernetes Theory (Foundational)

#### **1. What is Kubernetes?**

* Definition and role in modern DevOps
* Key problems Kubernetes solves (scaling, self-healing, deployments, etc.)

#### **2. Kubernetes Architecture**

* Master Node vs Worker Node
* Core components:

  * **API Server**
  * **etcd**
  * **Controller Manager**
  * **Scheduler**
  * **Kubelet**
  * **Kube Proxy**
  * **Container Runtime**

#### **3. Kubernetes Objects**

* Pod (smallest unit of deployment)
* ReplicaSet
* Deployment
* Service (ClusterIP, NodePort, LoadBalancer)
* Namespace
* ConfigMap & Secret
* PersistentVolume (PV) & PersistentVolumeClaim (PVC)
* StatefulSet & DaemonSet

#### **4. Cluster Networking**

* Pod-to-Pod communication
* Service networking
* CNI (Container Network Interface) plugins overview

#### **5. Controllers and Scheduling**

* How pods are scheduled
* Lifecycle of a Pod
* Health checks: Liveness and Readiness Probes

#### **6. Ingress and Load Balancing**

* Ingress Controllers
* Routing external traffic
* TLS termination

#### **7. Config & Storage Management**

* ConfigMaps vs Secrets
* Volumes in Kubernetes
* Persistent storage using PV/PVC

#### **8. RBAC and Security**

* Roles, ClusterRoles
* RoleBindings, ClusterRoleBindings
* ServiceAccounts
* Network Policies

#### **9. Logging and Monitoring (Overview)**

* Metrics Server
* Prometheus + Grafana
* Logging with Fluentd, ELK, etc.

#### **10. Helm (Optional for later)**

* Helm charts
* Helm v3 basics

  
---



# 📘 Kubernetes Theory Roadmap

A structured guide to build strong foundational knowledge of Kubernetes before moving to hands-on practice.

## 🔰 Level 1: Introduction & Fundamentals

### ✅ Goal: Understand what Kubernetes is and why it's used

- What is Kubernetes?
  - Definition
  - Use cases
  - History (Google Borg → CNCF)
- Kubernetes vs Docker
  - Orchestration vs containerization
- Core Concepts
  - Cluster
  - Node (Master & Worker)
  - Pod (smallest deployable unit)

## ⚙️ Level 2: Kubernetes Architecture

### ✅ Goal: Learn about cluster internals and major components

### Control Plane Components:
- kube-apiserver
- etcd
- kube-scheduler
- kube-controller-manager
- cloud-controller-manager

### Node Components:
- kubelet
- kube-proxy
- Container Runtime (Docker, containerd, CRI-O)

## 🧱 Level 3: Kubernetes Objects & Workloads

### ✅ Goal: Understand how resources are defined and managed

### Basic Objects:
- Pod
- ReplicaSet
- Deployment
- Namespace

### Advanced Workloads:
- StatefulSet
- DaemonSet
- Job / CronJob

### Declarative Management:
- Anatomy of a YAML manifest
- kubectl apply vs create

## 🌐 Level 4: Networking in Kubernetes

### ✅ Goal: Grasp how pods and services communicate

- Cluster Networking Basics
  - Pod-to-Pod networking
  - DNS in the cluster

- Kubernetes Services:
  - ClusterIP
  - NodePort
  - LoadBalancer
  - Headless Services

- Ingress:
  - Ingress Resource
  - Ingress Controllers
  - TLS Termination

- CNI (Container Network Interface):
  - Flannel
  - Calico
  - Cilium

## 🔐 Level 5: Security in Kubernetes

### ✅ Goal: Secure access and communication within the cluster

- RBAC (Role-Based Access Control):
  - Roles & RoleBindings
  - ClusterRoles & ClusterRoleBindings

- ServiceAccounts:
  - Assigning to Pods
  - API authentication

- Network Policies:
  - Restrict Pod-to-Pod traffic

- Secrets & ConfigMaps:
  - When to use which
  - Best practices

## 🗂️ Level 6: Configuration & Storage

### ✅ Goal: Manage data, secrets, and configurations properly

- ConfigMap:
  - Use with env variables or mounted volumes

- Secrets:
  - Base64 encoding
  - Use in workloads securely

- Volumes & Persistent Storage:
  - emptyDir
  - hostPath
  - PersistentVolume (PV)
  - PersistentVolumeClaim (PVC)
  - StorageClass & dynamic provisioning

## 📋 Level 7: Observability

### ✅ Goal: Monitor Kubernetes environments and applications

- Logs & Events:
  - kubectl logs
  - kubectl describe

- Metrics:
  - Metrics Server
  - Resource usage with kubectl top

- Monitoring Stack:
  - Prometheus
  - Grafana
  - Alertmanager

- Logging Stack:
  - Fluentd
  - Elasticsearch
  - Kibana (EFK Stack)

## 📦 Level 8: Helm - Kubernetes Package Manager

### ✅ Goal: Manage applications using Helm

- What is Helm?
  - Helm Charts
  - Templates and values

- Basic Helm Usage:
  - `helm install`
  - `helm upgrade`
  - `helm rollback`

- Chart Structure:
  - Chart.yaml
  - templates/
  - values.yaml

## ✅ Final Outcome:

By completing all levels, you should be able to:

- Explain Kubernetes architecture confidently
- Write and understand YAML manifests
- Configure networking, security, and storage
- Monitor applications and system health
- Use Helm for application deployment



---

## 🧩 What is Kubernetes?

**Kubernetes** (often abbreviated as **K8s**) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications.

### 🔧 Why Was Kubernetes Created?

In the era of microservices and containerization (especially using Docker), managing containers at scale became very complex. Running a few containers manually is manageable, but problems arise when you have:

* Hundreds of containers
* Many different services
* Dynamic scaling needs
* Failures and the need for self-healing
* Rolling updates and rollbacks

Kubernetes was designed to **solve these orchestration problems**.


### 🌍 Origins and History

* Kubernetes was originally developed by **Google**, based on its internal system **Borg**.
* It was open-sourced in **2014** and donated to the **Cloud Native Computing Foundation (CNCF)**.
* Now it’s supported by major cloud providers and companies (AWS, Azure, GCP, IBM, Red Hat, etc.)


### 🔄 What Does Kubernetes Do?

Kubernetes helps with:

| Capability                    | Description                                         |
| ----------------------------- | --------------------------------------------------- |
| **Deployment**                | Deploy applications and keep them running.          |
| **Scaling**                   | Automatically scale up/down based on load.          |
| **Self-healing**              | Restart crashed containers, reschedule failed ones. |
| **Service discovery**         | Assign internal DNS and IPs for communication.      |
| **Load balancing**            | Distribute traffic across services.                 |
| **Configuration management**  | Inject secrets and environment variables.           |
| **Rolling updates/rollbacks** | Update services with zero downtime.                 |


### 🏗️ Core Concepts at a Glance

| Concept        | Description                                              |
| -------------- | -------------------------------------------------------- |
| **Cluster**    | A group of machines running Kubernetes                   |
| **Node**       | A single machine (VM or physical), part of the cluster   |
| **Pod**        | The smallest deployable unit (can contain 1+ containers) |
| **Deployment** | Manages ReplicaSets to maintain desired Pods             |
| **Service**    | Provides a stable network endpoint for Pods              |
| **Namespace**  | Isolates groups of resources in the same cluster         |


### 📦 Kubernetes vs Docker

| Feature   | Docker                      | Kubernetes                             |
| --------- | --------------------------- | -------------------------------------- |
| Purpose   | Containerization            | Container orchestration                |
| Usage     | Run single containers       | Manage multi-container workloads       |
| CLI       | `docker`                    | `kubectl`                              |
| Ecosystem | Build, ship, run containers | Deploy, scale, and maintain containers |

Kubernetes **uses** Docker (or other runtimes like `containerd`) under the hood to run containers, but it manages them at scale.


### 💡 Key Takeaway

> Kubernetes is to containers what an operating system is to processes — it abstracts the infrastructure and provides automation, scalability, and management features for containerized applications.
