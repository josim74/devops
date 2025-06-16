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
Awesome! Let's dive into **Level 2: Kubernetes Architecture** — understanding how a Kubernetes cluster works internally is crucial to mastering it.


## ⚙️ Level 2: Kubernetes Architecture


### 🏗️ What is a Kubernetes Cluster?

A **Kubernetes cluster** is a set of machines (virtual or physical) that work together to run containerized applications. It consists of:

1. **Control Plane (Master Node)** — brain of the cluster
2. **Worker Nodes** — machines that run the actual applications (pods)


## 🧠 Control Plane Components (Runs on Master Node)

The **Control Plane** manages the entire cluster and makes decisions like scheduling, responding to cluster events, and maintaining cluster state.

| Component                    | Role                                                                                    |
| ---------------------------- | --------------------------------------------------------------------------------------- |
| **kube-apiserver**           | Front door of the cluster — accepts REST API requests (via `kubectl`, dashboards, etc.) |
| **etcd**                     | Distributed key-value store — stores all cluster state/configuration                    |
| **kube-scheduler**           | Assigns pods to nodes based on resources and constraints                                |
| **kube-controller-manager**  | Runs controllers like node, replication, and job controllers                            |
| **cloud-controller-manager** | Interacts with underlying cloud provider (optional on local clusters)                   |

> All communication in Kubernetes happens **through the API Server**, even internally.


## 🔧 Node Components (Runs on Worker Nodes)

Each **Worker Node** is responsible for running containerized workloads.

| Component             | Role                                                                                                             |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **kubelet**           | Agent running on each node that communicates with the control plane. Ensures containers are running as expected. |
| **kube-proxy**        | Handles networking — manages IP routing, NAT, and load balancing for services.                                   |
| **Container Runtime** | Software that runs containers (Docker, containerd, CRI-O)                                                        |


## 🖼️ Cluster Diagram

```
+-----------------------+                +---------------------------+
|     Control Plane     |                |        Worker Node        |
|-----------------------|                |---------------------------|
| kube-apiserver        | <=====>        | kubelet                   |
| etcd (store)          |                | kube-proxy                |
| kube-scheduler        |                | Container Runtime         |
| controller-manager(s) |                | +----------------------+  |
| cloud-controller      |                | |   Pod (1+ containers) | |
+-----------------------+                | +----------------------+  |
                                         +---------------------------+
```


## 🌀 Internal Communication Flow

1. You run: `kubectl apply -f my-app.yaml`
2. **kubectl sends the request to the API Server**: `kubectl` reads the YAML file and sends an **HTTP request** (usually `POST` or `PATCH`) to the **kube-apiserver**, depending on whether it's creating or updating resources. The request is authenticated and authorized via RBAC (Role-Based Access Control).
3. **kube-apiserver stores the desired state in etcd**: Once validated, the `kube-apiserver` stores the object definition (e.g., a Deployment) into the **etcd database**, which is the **single source of truth** for the cluster. Like - Object kind (Deployment), replica count, image, labels, selectors, ports, etc.
4. **kube-controller-manager notices the change**: The **Deployment Controller** (inside `kube-controller-manager`) is constantly watching the `apiserver` (via the **watch API**) for new or modified Deployments. It compares the current state vs the desired state. If 0 Pods are running and 3 are desired, it needs to create 3 Pods.
5. **Deployment controller creates a ReplicaSet:** The controller creates a **ReplicaSet** object and stores it via the `apiserver`. Then it asks the **ReplicaSet Controller** to create the required number of **Pod** objects.
6. **kube-scheduler assigns Pods to Nodes:** Now, there are unscheduled Pods (i.e., Pods without a Node assignment). The **kube-scheduler** watches the `apiserver` for unscheduled Pods. It evaluates - Node capacity (CPU, RAM), Node taints/tolerations, Pod affinity/anti-affinity, and Custom scheduling rules. Once it selects the best Node, it updates the Pod object with `.spec.nodeName`
7. **kubelet on the target node gets the instruction:** On each Node, a **kubelet** is running and constantly watches for Pod specs assigned to it (via the API Server). The kubelet sees that a new Pod needs to be created on that Node.
8. **kubelet talks to the container runtime:** The kubelet passes the Pod specification to the **container runtime** (e.g., containerd, Docker). The runtime pulls the specified container image from the registry (Docker Hub, ECR, GCR, etc.). It then starts the container(s) defined in the Pod spec.
9. **kubelet updates status:** kubelet informs the **apiserver** about the Pod’s actual status - "Pulling image...", "Started container", "Pod is running". This allows tools like `kubectl get pods` to show real-time information.
10. **kube-proxy enables networking:** If the Pod exposes a port and is part of a Service, **kube-proxy** sets up - `IPTables or IPVS rules for load balancing`, `DNS routing to the correct backend Pods`. This allows communication **within the cluster** and possibly **from outside** (if using NodePort/LoadBalancer/Ingress)
11. **Cluster is in desired state:** At this point - `Your Pods are scheduled`, `Containers are running`, `Services are reachable`, `Status is monitored`. If anything fails (e.g., container crash), the **controller manager** ensures the system tries to restore the desired state (e.g., restart the Pod).


## 🧪 Additional Notes

* All master components **can be HA (Highly Available)** in production.
* The control plane can **run on a dedicated node** or **on worker nodes** in small setups (like Minikube).
* Kubernetes is **declarative**: You tell it what you want, and it tries to make it happen and maintain it.


### ✅ Summary

* **Control Plane = brains** of the cluster
* **Worker Nodes = muscle**, running actual workloads
* All components communicate through the **kube-apiserver**
* Cluster state is **persisted in etcd**

Great! Let’s move on to **Level 3: Kubernetes Objects & Workloads** — the building blocks of everything you deploy in Kubernetes.


## 🧱 Level 3: Kubernetes Objects & Workloads

These are the core **resources** you define in YAML files and manage using `kubectl`. They represent your applications, configurations, and how Kubernetes should manage them.


### 🔹 1. **Pods** (The smallest deployable unit)

A **Pod** is a wrapper around one or more containers that:

* Share the same network namespace (IP, port space)
* Can communicate via `localhost`
* Can share storage volumes

Most of the time, a Pod runs a **single container**. You might use multiple containers in one Pod if they must run together (e.g., log sidecar + main app).

📄 Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: app
      image: nginx
```


### 🔹 2. **ReplicaSet**

Ensures a specified **number of Pod replicas** are running at any given time.

* Automatically replaces crashed Pods
* Scales up/down as needed
* Used **indirectly** — usually managed by a Deployment

📄 Example:

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name: nginx
          image: nginx
```


### 🔹 3. **Deployment**

A **higher-level controller** that manages ReplicaSets and provides:

* **Declarative updates**
* **Rollbacks**
* **Rollouts**
* Version tracking

This is the most commonly used object for running stateless applications.

📄 Example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx
```


### 🔹 4. **StatefulSet**

Used for **stateful applications**, like databases.

* Gives each Pod a **stable identity** (DNS, storage)
* Ensures **ordered startup and shutdown**
* Works with **PersistentVolumeClaims**

📄 Use cases:

* MySQL, MongoDB, Elasticsearch


### 🔹 5. **DaemonSet**

Ensures a copy of a Pod **runs on all (or some) nodes**.

* Often used for:

  * Logging agents (Fluentd)
  * Monitoring agents (Node Exporter)
  * Security scanners

📄 Example use:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-monitor
spec:
  selector:
    matchLabels:
      name: monitor
  template:
    metadata:
      labels:
        name: monitor
    spec:
      containers:
        - name: monitor-agent
          image: monitoring/agent
```


### 🔹 6. **Job and CronJob**

* **Job**: Runs a task to **completion**, e.g., a backup script.
* **CronJob**: Runs Jobs **on a schedule**, like cron in Linux.

📄 Job Example:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
    spec:
      containers:
        - name: hello
          image: busybox
          command: ["echo", "Hello Kubernetes"]
      restartPolicy: Never
```


### 📂 7. Namespaces

Namespaces allow you to **partition a cluster** into multiple environments:

* Isolate workloads (dev, staging, prod)
* Apply resource quotas and RBAC policies per namespace

📄 Create:

```bash
kubectl create namespace my-namespace
```


### 🧬 8. Anatomy of a Kubernetes YAML File

Every Kubernetes manifest has a common structure:

```yaml
apiVersion: apps/v1        # API version
kind: Deployment           # Type of resource
metadata:                  # Name, labels
  name: my-app
spec:                      # Desired state
  replicas: 3
  selector: {...}
  template:
    metadata: {...}
    spec:
      containers:
        - name: app
          image: my-image
```


### ⚙️ `kubectl` Tips

* `kubectl apply -f file.yaml` — create or update resources
* `kubectl get pods` — list Pods
* `kubectl describe pod pod-name` — detailed info and events
* `kubectl delete -f file.yaml` — delete defined resources


### ✅ Summary

| Object      | Purpose                      | Typical Use Case               |
| ----------- | ---------------------------- | ------------------------------ |
| Pod         | Runs 1+ containers           | Base unit in Kubernetes        |
| ReplicaSet  | Maintains a stable Pod count | Used internally by Deployments |
| Deployment  | Manages stateless apps       | Web apps, microservices        |
| StatefulSet | Runs stateful apps           | Databases, brokers             |
| DaemonSet   | Runs a Pod on every Node     | Monitoring, logging            |
| Job         | Run-to-completion task       | One-time tasks, scripts        |
| CronJob     | Scheduled recurring Job      | Backups, reports               |
| Namespace   | Isolates resources           | Multi-team, multi-env          |

Awesome! Let’s dive into one of the most critical topics in Kubernetes: **Level 4: Networking in Kubernetes**.


## 🌐 Level 4: Networking in Kubernetes

Networking is essential for Kubernetes because it enables:

* Communication between **Pods**
* Access to services **within the cluster**
* Exposure of services **to the outside world**


### 📦 1. Kubernetes Networking Model

Kubernetes follows **two key rules**:

1. **Every Pod gets its own IP address**
2. **All Pods can communicate with each other without NAT**

This means:

* No need to map container ports to host ports.
* Flat network across the cluster.


### 🧱 2. Basic Components of Networking

| Component             | Purpose                                                       |
| --------------------- | ------------------------------------------------------------- |
| **Pod Network (CNI)** | Enables Pod-to-Pod communication across Nodes                 |
| **Service**           | Provides a stable IP and DNS name for a group of Pods         |
| **kube-proxy**        | Handles routing traffic to the right Pods using iptables/IPVS |
| **Ingress**           | Manages external HTTP/S access to services                    |


## 🛣️ 3. Container Network Interface (CNI)

* Kubernetes itself doesn’t implement networking — it uses **CNI plugins**.
* Common CNI providers:

  * **Calico**
  * **Flannel**
  * **Cilium**
  * **Weave**

These:

* Assign IP addresses to Pods
* Set up routing between Nodes and Pods


### 🔗 4. Service Types in Kubernetes

Kubernetes **Service** is an abstraction to expose your app running in Pods.

#### 📘 ClusterIP (default)

* Accessible **only within** the cluster
* Ideal for **internal microservices**

```yaml
spec:
  type: ClusterIP
```

#### 🌐 NodePort

* Exposes service on **<NodeIP>:<Port>**
* Works outside the cluster
* Limited port range (30000–32767)

```yaml
spec:
  type: NodePort
```

#### 🚀 LoadBalancer

* Uses **cloud provider’s load balancer**
* Best for production-grade **external traffic**
* Requires cloud support (e.g., AWS, GCP)

```yaml
spec:
  type: LoadBalancer
```

#### 🌍 ExternalName

* Maps the service to an **external DNS name**
* Acts as a proxy

```yaml
spec:
  type: ExternalName
  externalName: my.db.com
```


## 🧭 5. DNS in Kubernetes

* Every service gets a **DNS name** like:

  ```
  <service>.<namespace>.svc.cluster.local
  ```
* The **CoreDNS** service handles this internally.
* Example:

  * You can access `my-api` from another Pod with:

    ```
    http://my-api.default.svc.cluster.local
    ```


## 🌉 6. Ingress & Ingress Controller

* **Ingress** allows HTTP/S access to Services using:

  * Hostnames
  * Paths (e.g., `/api`, `/admin`)
* Requires an **Ingress Controller** like:

  * NGINX Ingress Controller
  * Traefik
  * AWS ALB Ingress Controller

📄 Example:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
    - host: myapp.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```


### 🔐 7. Network Policies

By default, **all Pods can talk to each other**. If you want to **restrict communication**, use **NetworkPolicies**.

* Define:

  * Which Pods can **ingress** (receive) traffic
  * Which Pods can **egress** (send) traffic

📄 Example:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-external
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: allowed-pod
```


### 🧠 Summary Table

| Concept                | Role                               | Scope/Example                       |
| ---------------------- | ---------------------------------- | ----------------------------------- |
| Pod IP                 | Unique to each Pod                 | Pod-to-Pod communication            |
| Service (ClusterIP)    | Internal load balancing            | microservice-to-microservice        |
| Service (NodePort)     | External access via Node IP + port | dev/test cluster external access    |
| Service (LoadBalancer) | External access with cloud LB      | Production deployments on cloud     |
| Ingress                | Advanced HTTP routing              | `myapp.com/api` → `backend-service` |
| CNI Plugin             | Provides Pod IPs, routing          | Flannel, Calico, Cilium             |
| NetworkPolicy          | Restricts Pod-level network access | Like firewall rules for Pods        |

Perfect! Now we move into **Level 5: Storage in Kubernetes** — a crucial concept when running **stateful applications**, backups, caching, and persistent user data.


## 💾 Level 5: Storage in Kubernetes

Kubernetes abstracts storage using a concept called **Volumes**, which can outlive containers and connect to external storage systems.


### 📦 1. Volumes (Basic)

* A **Volume** in Kubernetes is a directory accessible to containers in a Pod.
* Unlike container storage (`/tmp`, etc.), data in a volume **persists across container restarts**.
* Volumes are declared in the Pod’s spec and mounted inside containers.

📄 Basic Example:

```yaml
spec:
  volumes:
    - name: data-volume
      emptyDir: {}  # Creates temporary volume in node
  containers:
    - name: app
      image: busybox
      volumeMounts:
        - mountPath: /data
          name: data-volume
```

🔹 `emptyDir` is erased when the Pod is deleted — suitable for scratch space or caching.


### 🗃️ 2. Persistent Volumes (PV) & Persistent Volume Claims (PVC)

To support **persistent** storage (e.g., database data), Kubernetes separates storage into two objects:

| Resource                        | Purpose                                                       |
| ------------------------------- | ------------------------------------------------------------- |
| **PersistentVolume (PV)**       | Represents an actual storage resource (disk, NFS, cloud disk) |
| **PersistentVolumeClaim (PVC)** | A request for a specific amount/type of storage               |

📄 **1. Create a PersistentVolume:**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
```

📄 **2. Create a PersistentVolumeClaim:**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

📄 **3. Use in a Pod:**

```yaml
volumes:
  - name: data-storage
    persistentVolumeClaim:
      claimName: my-pvc
```


### 🔁 3. Dynamic Provisioning

If you’re on a cloud or using a storage plugin, you can **dynamically provision storage** using a **StorageClass**.

📄 Example:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/aws-ebs  # Or GCP, Azure
parameters:
  type: gp2
```

Then in your PVC:

```yaml
spec:
  storageClassName: fast-storage
```

Kubernetes will create a disk on-the-fly when the PVC is created.


### 📑 4. Access Modes

| Mode                  | Description                             |
| --------------------- | --------------------------------------- |
| `ReadWriteOnce (RWO)` | Mounted as read-write by **one** node   |
| `ReadOnlyMany (ROX)`  | Mounted read-only by **many** nodes     |
| `ReadWriteMany (RWX)` | Mounted as read-write by **many** nodes |

Not all storage backends support all modes. RWX is rare on cloud block storage but available with NFS/Ceph/etc.


### 🧊 5. Volume Types

| Volume Type             | Description                    |
| ----------------------- | ------------------------------ |
| `emptyDir`              | Temporary scratch space        |
| `hostPath`              | Mounts a path from host node   |
| `nfs`                   | Mounts external NFS            |
| `awsElasticBlockStore`  | AWS EBS volume                 |
| `configMap`             | Mount config data as files     |
| `secret`                | Mount secrets (base64-encoded) |
| `persistentVolumeClaim` | Bind to a PersistentVolume     |


### 🔐 6. Secrets & ConfigMaps as Volumes

* **Secrets** store sensitive data (e.g., passwords, API keys)
* **ConfigMaps** store configuration (e.g., environment settings)

📄 Mount as file or inject as env variable:

```yaml
volumes:
  - name: config
    configMap:
      name: app-config
```


### 💡 7. StatefulSet & VolumeClaimTemplates

StatefulSets use **VolumeClaimTemplates** to give each Pod its own volume:

📄 Example:

```yaml
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

Result:

* pod-0 gets `data-pod-0`
* pod-1 gets `data-pod-1`


### ✅ Summary

| Concept                                | Role                                       |
| -------------------------------------- | ------------------------------------------ |
| `Volume`                               | Temporary shared directory for a Pod       |
| `PersistentVolume (PV)`                | Actual provisioned disk/storage            |
| `PersistentVolumeClaim (PVC)`          | Request for storage from a Pod             |
| `StorageClass`                         | Defines how dynamic storage is provisioned |
| `StatefulSet` + `VolumeClaimTemplates` | Per-Pod persistent disks                   |

