This part is being continued from [Django with Docker and Kubernetes](https://github.com/josim74/devops/blob/main/ci_cd/django_on_docker_kubernetes.md)

## Create kubernetes manifest files using project files as follows
1. Create `django-configmap.yml` and `django-secret.yml` from `env.prod` and `env.prod.db`

    - `django-configmap.yml` file
        ```yml
        # django-configmap.yml
        apiVersion: v1
        kind: ConfigMap
        metadata:
        name: django-config
        namespace: default
        data:
        DJANGO_ALLOWED_HOSTS: "localhost,127.0.0.1,[::1]"
        SQL_ENGINE: "django.db.backends.postgresql"
        SQL_DATABASE: "hello_django_prod"
        SQL_USER: "hello_django"
        SQL_HOST: "db"
        SQL_PORT: "5432"
        DATABASE: "postgres"
        ```
    - `django-secret.yml` file. Secrets must be base64 encoded

        ```yml
        apiVersion: v1
        kind: Secret
        metadata:
        name: django-secret
        namespace: default
        type: Opaque
        data:
        SECRET_KEY: "Y2hhbmdlX21l"  # Base64-encoded "change_me"
        POSTGRES_USER: "aGVsbG9fZGphbmdv"  # Base64-encoded "hello_django"
        POSTGRES_PASSWORD: "aGVsbG9fZGphbmdv"  # Base64-encoded "hello_django"
        POSTGRES_DB: "aGVsbG9fZGphbmdvX3Byb2Q="  # Base64-encoded "hello_django_prod"
        ```
        To encode a string to base64, run command `echo -n change_me | base64` for decode (if you need to verify that rightly encoded or not) `echo SGVsbG8K | base64 -D`
    - Now, run the commands
        ```bash
        kubectl apply -f django-configmap.yml
        kubectl apply -f django-secret.yml
        ```
        Verify with `kubectl get configmap` and `kubectl get secret`
        
2. Create persistent volume claims `django-pvc.yml` file to persist the data
    ```yml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
    name: postgres-data-pvc
    namespace: default
    spec:
    accessModes:
        - ReadWriteOnce
    resources:
        requests:
        storage: 5Gi
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
    name: static-files-pvc
    namespace: default
    spec:
    accessModes:
        - ReadWriteMany
    resources:
        requests:
        storage: 1Gi
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
    name: media-files-pvc
    namespace: default
    spec:
    accessModes:
        - ReadWriteMany
    resources:
        requests:
        storage: 1Gi
    ```
    - Run the command `kubectl apply -f django-pvc.yml`

3. Create `postgres-deployment.yml` file. Get necessary info from `docker-compose.prod.yml`
    ```yml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: postgres
    namespace: default
    spec:
    replicas: 1
    selector:
        matchLabels:
        app: postgres
    template:
        metadata:
        labels:
            app: postgres
        spec:
        containers:
            - name: postgres
            image: postgres:15
            resources:
                limits:
                memory: "512Mi"
                cpu: "500m"
                requests:
                memory: "256Mi"
                cpu: "250m"
            ports:
                - containerPort: 5432
            envFrom:
                - secretRef:
                    name: django-secret
            volumeMounts:
                - name: postgres-data
                mountPath: /var/lib/postgresql/data
        volumes:
            - name: postgres-data
            persistentVolumeClaim:
                claimName: postgres-data-pvc
    ```
    - Run command `kubectl apply -f postgress-deployment.yml`
    - To verify `kubectl get deployment` It will take some to to be in ready state

4. Create `django-deployment.yml` file. Get necessary info from `docker-compose.prod.yml`
    ```yml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: django-app
    namespace: default
    spec:
    replicas: 1
    selector:
        matchLabels:
        app: django-app
    template:
        metadata:
        labels:
            app: django-app
        spec:
        containers:
            - name: django
            image: josim92/django-projects:web1.0
            resources:
                limits:
                memory: "512Mi"
                cpu: "500m"
                requests:
                memory: "256Mi"
                cpu: "250m"
            ports:
                - containerPort: 8000
            envFrom:
                - configMapRef:
                    name: django-config
                - secretRef:
                    name: django-secret
            volumeMounts:
                - name: static-files
                mountPath: /home/app/web/staticfiles
                - name: media-files
                mountPath: /home/app/web/mediafiles
            command: ["gunicorn", "hello_django.wsgi:application", "--bind", "0.0.0.0:8000"]
        volumes:
            - name: static-files
            persistentVolumeClaim:
                claimName: static-files-pvc
            - name: media-files
            persistentVolumeClaim:
                claimName: media-files-pvc
    ```
    - Run command `kubectl apply -f django-deployment.yml`
    - To verify `kubectl get deployment`
4. Create `nginx-deployment.yml` file. Get necessary info from `docker-compose.prod.yml`
    ```yml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: nginx
    namespace: default
    spec:
    replicas: 1
    selector:
        matchLabels:
        app: nginx
    template:
        metadata:
        labels:
            app: nginx
        spec:
        containers:
            - name: nginx
            image: nginx:1.25
            resources:
                limits:
                memory: "512Mi"
                cpu: "500m"
                requests:
                memory: "256Mi"
                cpu: "250m"
            ports:
                - containerPort: 80
            volumeMounts:
                - name: static-files
                mountPath: /home/app/web/staticfiles
                - name: media-files
                mountPath: /home/app/web/mediafiles
                - name: nginx-config
                mountPath: /etc/nginx/conf.d
        volumes:
            - name: static-files
            persistentVolumeClaim:
                claimName: static-files-pvc
            - name: media-files
            persistentVolumeClaim:
                claimName: media-files-pvc
            - name: nginx-config
            configMap:
                name: nginx-config
    ```
    - Run command `kubectl apply -f nginx-deployment.yml`
    - To verify `kubectl get deployment` The nginx deploymet will not be in ready state until you apply the 'django-service.yml` file.

6. Create `nginx-configmap.yml` file. Get the content from `nginx.conf` file
    ```yml
    apiVersion: v1
    kind: ConfigMap
    metadata:
    name: nginx-config
    namespace: default
    data:
    nginx.conf: |
        upstream hello_django {
            server django-app:8000;
        }

        server {
            listen 80;

            location / {
                proxy_pass http://hello_django;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $host;
                proxy_redirect off;
                client_max_body_size 100M;
            }

            location /static/ {
                alias /home/app/web/staticfiles/;
            }

            location /media/ {
                alias /home/app/web/mediafiles/;
            }
        }
    ```
    - Run command `kubectl apply -f nginx-configmap.yml`
    - To verify `kubectl get configmap`
7. Create `django-services.yml` file. It is also okay to create separate files for each service.
    ```yml
    apiVersion: v1
    kind: Service
    metadata:
    name: postgres
    namespace: default
    spec:
    type: ClusterIP
    ports:
        - port: 5432
        targetPort: 5432
    selector:
        app: postgres
    ---
    apiVersion: v1
    kind: Service
    metadata:
    name: django-app
    namespace: default
    spec:
    type: ClusterIP
    ports:
        - port: 8000
        targetPort: 8000
    selector:
        app: django-app
    ---
    apiVersion: v1
    kind: Service
    metadata:
    name: nginx
    namespace: default
    spec:
    type: ClusterIP
    ports:
        - port: 80
        targetPort: 80
    selector:
        app: nginx
    ```
    - Run command `kubectl apply -f django-services.yml`
    - To verify `kubectl get svc`
8. Create `django-ingress.yml` file for load balancing.
    ```yml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
    name: django-ingress
    namespace: default
    annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
    spec:
    rules:
        - host: django.local # Write your domain name here
        http:
            paths:
            - path: /
                pathType: Prefix
                backend:
                service:
                    name: nginx
                    port:
                    number: 80
    ```
    - Run command `kubectl apply -f django-ingress.yml`
    - To verify `kubectl get ingress`
    - You must enable ingress addon in minikube. Run the command `minikube addons enable ingress`
    - Ensure the ingress controller is running. Run the command to check `kubectl get pods -n ingress-nginx`
    - Expose ingress via a minikube tunnel. Run the command `minikube tunnel`
    - Verify DNS mapping and add/update `/etc/hosts` file with adding following line `127.0.0.1 localhost django.local`
    - Open browser and hit 'django.local`

## Troubleshooting
- Check pod log `kubectl logs <pod name>`
- Check pod insights/issues `kubectl describe pod <pod name>`
- Validate django-app connectivity using a temporary kubectl port-forward `kubectl port-forward svc/django-app 8000:8000` then test in browser 'localhost:8000`

## Here I have mentioned some best practices we can implement
Though till now we have come up with the production best practices. But there are more best practices we can implement here.
1. **Resource Requests and Limits (already applied):**
Define resource requests and limits to ensure fair resource allocation and stability. Example:
    ```yml
    resources:
    requests:
        memory: "256Mi"
        cpu: "500m"
    limits:
        memory: "512Mi"
        cpu: "1"
    ```
    Apply this to all container specifications in your manifests.

2. **Liveness and Readiness Probes:**
Add livenessProbe and readinessProbe to ensure the health of the containers and enable Kubernetes to restart or route traffic appropriately.

    Example for django-app:
    ```yaml
    livenessProbe:
    httpGet:
        path: /health
        port: 8000
    initialDelaySeconds: 5
    periodSeconds: 10
    readinessProbe:
    httpGet:
        path: /health
        port: 8000
    initialDelaySeconds: 5
    periodSeconds: 10
    ```
    Example for nginx:
    ```yaml
    livenessProbe:
    httpGet:
        path: /
        port: 80
    initialDelaySeconds: 5
    periodSeconds: 10
    readinessProbe:
    httpGet:
        path: /
        port: 80
    initialDelaySeconds: 5
    periodSeconds: 10
    ```
    You’ll need to implement a /health endpoint in your Django app.

3. **Namespace Isolation:**
Use a dedicated namespace for your application to provide better isolation and organization:
    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
    name: django-app-namespace
    ```
    Update all resource definitions with `namespace: django-app-namespace`

4. **Configurations and Secrets:**
Configurations and secrets are managed in ConfigMaps and Secrets but aren't encrypted at rest.
The SECRET_KEY is base64-encoded but not truly secure.
So the best Practice is to use tools like Sealed Secrets or HashiCorp Vault for managing secrets securely.
Avoid hardcoding sensitive values in manifests. Instead, use external tools to inject these securely into the cluster.

5. **Rolling Updates and Deployment Strategy:**
Currently the default deployment strategy is used. But for best practice, specify a rolling update strategy with health checks to avoid downtime during updates -
    ```yaml
    strategy:
    type: RollingUpdate
    rollingUpdate:
        maxUnavailable: 25%
        maxSurge: 1
    ```
6. **Autoscaling:**
Currently manual scaling is required. The best practice is to add Horizontal Pod Autoscaler (HPA) for django-app and nginx to handle varying loads dynamically -

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
    name: django-app-hpa
    spec:
    scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: django-app
    minReplicas: 2
    maxReplicas: 10
    metrics:
        - type: Resource
        resource:
            name: cpu
            target:
            type: Utilization
            averageUtilization: 80
    ```
7. **Static and Media File Management:**
Currently static and media files are stored on PersistentVolumes (PVs). But the best practice is use a scalable file storage solution like AWS S3, Google Cloud Storage, or MinIO for production-grade environments.
Update the Django app to serve static and media files from the cloud.

8. **Logging and Monitoring:**
Currently no centralized logging or monitoring is defined. So, we should integrate a logging solution like EFK (Elasticsearch, Fluentd, Kibana) or Loki (Grafana Loki).
Set up monitoring with Prometheus and Grafana.

9. **Network Policies:**
No network policies are defined in our current system.But we should restrict traffic between services and pods to enhance security -

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
    name: allow-django-nginx
    spec:
    podSelector:
        matchLabels:
        app: django-app
    policyTypes:
        - Ingress
    ingress:
        - from:
            - podSelector:
                matchLabels:
                app: nginx
    ```
10. **Persistent Volume Configuration:**
Persistent Volumes (PVs) are used, but storage classes are not specified in our current system. We should use dynamic provisioning with storage classes for better scalability and flexibility -

    ```yaml
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
    name: fast
    provisioner: kubernetes.io/aws-ebs
    parameters:
    type: gp2
    fsType: ext4
    reclaimPolicy: Retain
    allowVolumeExpansion: true
    ```

    Update PVCs to use this storage class:
    ```yaml
    spec:
    storageClassName: fast
    ```
11. **Security Best Practices:**
Ensure pods are run with the least privilege by adding a securityContext -
    ```yaml
    securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    ```
    Define PodDisruptionBudget to maintain high availability -
    ```yaml
    apiVersion: policy/v1
    kind: PodDisruptionBudget
    metadata:
    name: django-app-pdb
    spec:
    minAvailable: 1
    selector:
        matchLabels:
        app: django-app
    ```
12. **Readiness for Scale:**
To handle increased traffic use a LoadBalancer service for external access if applicable. Plan for resource scaling based on traffic patterns.