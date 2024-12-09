# Django with Docker and Kubernetes
## Dependencies
Django v4.2.3
Docker v24.0.2
Python v3.11.4

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

## Overview

Kubernetes is an open-source platform designed to automate deploying, scaling, and operating containerized applications. It helps manage clusters of containers at scale and provides a robust ecosystem for container orchestration.

## Django
1. Project setup
   ```bash
   mkdir django-on-docker && cd django-on-docker
   mkdir app && cd app
   python3 -m venv env
   source env/bin/activate
   (env)$ pip install django==4.2.3
   (env)$ django-admin startproject hello_django .
   (env)$ python manage.py migrate
   (env)$ python manage.py runserver
   ```
   - Check Django welcome screen on 'localhost:8000' and kill the server once done
   - Then exit `deactivate` and remove `rm -rf ./env` the venv. We now have a simple django project to work with

2. Create `django-on-docker/app/requirements.txt` file
   ```bash
   Django==4.2.3
   ```
3. Architecture should look like
   ```bash
   └── app
    ├── hello_django
    │   ├── __init__.py
    │   ├── asgi.py
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    ├── manage.py
    └── requirements.txt
   ```

## Docker
1. Create `django-on-docker/Dockerfile` file
   ```yaml
   # pull official base image
    FROM python:3.11.4-slim-buster

    # set work directory
    WORKDIR /usr/src/app

    # set environment variables
    ENV PYTHONDONTWRITEBYTECODE 1
    ENV PYTHONUNBUFFERED 1

    # install dependencies
    RUN pip install --upgrade pip
    COPY ./requirements.txt .
    RUN pip install -r requirements.txt

    # copy project
    COPY . .
   ```
2. Create `docker-on-docker/docker-compose.yml` file
   ```yaml
    version: '3.8'

    services:
    web:
        build: ./app
        command: python manage.py runserver 0.0.0.0:8000
        volumes:
        - ./app/:/usr/src/app/
        ports:
        - 8000:8000
        env_file:
        - ./.env.dev
   ```
3. Update `app/hello_django/settings.py`
    ```python
    import os # At the top

    SECRET_KEY = os.environ.get("SECRET_KEY")

    DEBUG = bool(os.environ.get("DEBUG", default=0))

    # 'DJANGO_ALLOWED_HOSTS' should be a single string of hosts with a space between each.
    # For example: 'DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]'
    ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS").split(" ")
    ```
4. Create `django-on-docker/.env.dev`
    ```python
    DEBUG=1
    SECRET_KEY=foo
    DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
    ```

5. Build docker image using compose file
    ```bash
    docker-compose build
    ```
6. Run the container once built
    ```bash
    docker-compose up -d
    ```
    - Navigate to http://localhost:8000 to again view the welcome screen
## Postgres
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

