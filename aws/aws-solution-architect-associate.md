# AWS Solution Architect Associate Exam Preparation

AWS services are categorized based on their **scope of operation**, which can be:  

1. **Global Services** – Operate across all AWS regions and are not tied to a specific region or availability zone.  
2. **Regional Services** – Available within a specific AWS region but can span multiple Availability Zones within that region.  
3. **Availability Zone (AZ)-Specific Services** – Operate within a single Availability Zone within a region.  

### **1. Global AWS Services**
These services are not bound to a specific region and are accessible worldwide. Examples include:
- **AWS Identity and Access Management (IAM)** – Manages users, roles, and permissions across AWS.
- **Amazon Route 53** – A scalable domain name system (DNS) service.
- **AWS CloudFront** – A global content delivery network (CDN).
- **AWS WAF & AWS Shield** – Web application firewall and DDoS protection.
- **AWS Organizations** – Centralized account management across AWS accounts.
- **AWS Artifact** – Compliance and security-related documentation.
- **AWS Security Token Service (STS)** – Issues temporary AWS credentials.
- **AWS Control Tower** – Manages multi-account AWS environments.
- **AWS Marketplace** – A digital catalog for AWS solutions.
- **Amazon Global Accelerator** – Improves global application performance.

### **2. Regional AWS Services**
These services operate within a specific AWS **region** but can span multiple Availability Zones within that region:
- **Amazon EC2** – Virtual machine instances.
- **Amazon S3** – Object storage (buckets are region-scoped).
- **Amazon RDS** – Managed relational database service.
- **Amazon DynamoDB** (but with global tables option).
- **Amazon VPC** – Virtual networking environment.
- **AWS Lambda** – Serverless compute.
- **Amazon ECS & Amazon EKS** – Container orchestration services.
- **Amazon API Gateway** – Managed API service.
- **AWS Glue** – Serverless ETL service.
- **Amazon Redshift** – Data warehousing.
- **AWS Step Functions** – Workflow orchestration.
- **AWS Backup** – Centralized backup service.
- **Amazon Elastic File System (EFS)** – Managed file storage for Linux.
- **Amazon FSx** – Managed file system (Windows and Lustre).
- **Systems Manager (Operational Management)**

### **3. Availability Zone (AZ)-Specific AWS Services**
These services operate at an **Availability Zone** level, meaning data and operations are specific to a single AZ:
- **Amazon EC2 Instances** – Each instance runs in a single AZ.
- **Amazon Elastic Block Store (EBS)** – Persistent storage attached to EC2 (bound to a single AZ).
- **AWS Local Zones** – Provide low-latency compute and storage outside major AWS regions.
- **Amazon ElastiCache (Redis/Memcached)** – High-performance caching in a single AZ (though multi-AZ is possible).
- **AWS Outposts** – On-premises AWS infrastructure with local compute and storage.

### **4. Multi-Region Services**
Some services can span multiple regions or are designed for cross-region functionality:
- **S3 Cross-Region Replication** (replicates data across regions)
- **DynamoDB Global Tables** (replicates data across regions)
- **RDS Read Replicas** (can be created in different regions)
- **CloudFront** (distributes content globally with edge locations)
- **Route 53** (global DNS service with health checks and routing policies)
- **AWS Backup** (supports cross-region backups)
- **AWS Global Accelerator** (improves availability and performance across regions)

### **5. Edge Locations**
Edge locations are used by services that deliver content globally:
- **CloudFront** (caches content at edge locations)
- **Lambda@Edge** (runs Lambda functions at edge locations)
- **Route 53** (resolves DNS queries using edge locations)

### **6. AWS Region and Availability Zone Structure**
- **Regions**: Geographically separate areas (e.g., `us-east-1`, `ap-south-1`).
- **Availability Zones (AZs)**: Isolated data centers within a region (e.g., `us-east-1a`, `us-east-1b`).
- **Local Zones**: Extend regions to bring services closer to users (e.g., for low-latency applications).
- **Wavelength Zones**: Embed AWS services within 5G networks for ultra-low latency.

### **7. How to Check Service Availability**
You can check the availability of AWS services in specific regions using:
- **AWS Global Infrastructure Map**: [AWS Global Infrastructure](https://aws.amazon.com/about-aws/global-infrastructure/)
- **AWS Service Endpoints**: [AWS Regions and Endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html)
- **AWS Management Console**: The console shows region-specific services.

### **8. Key Considerations**
- **Data Residency**: Some services store data in specific regions to comply with local laws.
- **Latency**: Choose regions and AZs close to your users for better performance.
- **Disaster Recovery**: Use multi-region or multi-AZ architectures for high availability.

### IAM and AWS CLI:




