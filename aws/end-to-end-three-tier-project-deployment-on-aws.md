## Info
1. Source code link: https://github.com/Learn-It-Right-Way/lirw-react-node-mysql-app
1. Branch: feature/add-logging
2. Edit source code
   - Add logging in the backend and frontend
   - Add a new route to health check
# AWS
## Configure route53
Create a public hosted zone with your domain name
```
Route 53 > Hosted zones > Create hosted zone >
    Domain name: josim 74.life
    <x> Public hosted zone
> Create
<x> josim74.life >
```
- Collect name servers and assign to your domain registrar

## Request SSL certificate from ACM
```
ACM > Certificates > Request a certificate >
    Domain name: josim74.life 
    <x> DNS validation recommended 
    <x> RSA 2048
> Create
> Create records in Route53
    <Check all>
> Create
```

## Create VPCs and subnets
```
VPC > Your VPCs > Create VPC > 
    <x> VPC and more
    <x> Auto generation
    Number of availability zones: 2
    Number of public subnets: 2
    Number of private subnets: 4
    VPC endpoint: None 
    <x> Enable DNS hostnames 
    <x> Enable DNS resolution
> Create VPC
```
  - Modify the public subnets to auto add public IP to EC2 instances 

## Create security groups
1. Security group for Bastion host
    ```
    VPC > Security groups > Create security group >
        Name: bastion-sg
        Description: Bastion security group
        VPC: <Created VPC>
        Inbound rules:
        SSH - TCP - 22 - Anywhere (0.0.0.0/0)
    > Create
    ```
2. Presentation tier load balancer
   ``` 
   VPC > Security groups > Create security group >
        Name: presentation-tier-alb-sg
        Description: Load balancer security group
        VPC: <Created VPC>
        Inbound rules:
            HTTP - TCP - 80 - Anywhere (0.0.0.0/0)
    > Create (No HTTPS)
    ```
3. Presentation tire EC2 security group
    ```
    VPC > Security groups > Create security group >
        Name: presentation-tier-ec2-sg
        Description: Presentation tier EC2 security group
        VPC: <Created VPC>
        Inbound rules:
        SSH - TCP - 22 - Bastion SG
        HTTP - TCP - 80 - presentation-tier-alb-sg
    > Create
    ```
4. Application tier load balancer
    ```
    VPC > Security groups > Create security group >
        Name: application-tier-alb-sg
        Description: Application tier load balancer security group
        VPC: <Created VPC>
        Inbound rules:
        All traffic - TCP - 80 - presentation-tier-ec2-sg
    > Create
    ```
5. Application tier EC2 security group
    ```
    VPC > Security groups > Create security group >
        Name: application-tier-ec2-sg
        Description: Application tier EC2 security group
        VPC: <Created VPC>
        Inbound rules:
        SSH - TCP - 22 - Bastion SG
        HTTP - TCP - 3200 - application-tier-alb-sg
    > Create
    ```
6. Database tier RDS security group
    ```
    VPC > Security groups > Create security group >
        Name: database-tier-rds-sg
        Description: Database tier RDS security group
        VPC: <Created VPC>
        Inbound rules:
        MySQL/Aurora - TCP - 3306 - application-tier-ec2-sg
        MySQL/Aurora - TCP - 3306 - bastion-sg
    > Create
    ```
## Launching EC2 instances
Launching bastion host
```
EC2 > Instances > Launch instance >
    Name: bastion-host
    AMI: Amazon Linux 2 AMI (HVM), SSD Volume Type Instance type: t2.micro
    Key pair: <Create one if not exist>
    Network: <Created VPC>
    Subnet: <Public subnet>
    Auto-assign Public IP: Enable Security Group: bastion-sg
> launch
```
## Setting up data tire with RDS MySQL instance
1. Creating DB subnet group
    ```
    RDS > Subnet groups > Create DB subnet group >
        Name: dev-db-subnet-group
        Description: Development database subnet group
        VPC: <Created VPC>
        Subnets: ‹Private subnets on each availability zone>
    > Create
    ```
2. Creating RDS Database
    ```
    RDS > Create database > 
        <x> Standared create 
        <x> MySQL
        <x> MySQL Community
        Engine Version: 8.0.35
        <x> Dev/Test
        <x> Multi-AZ DB instance
        DB instance identifies: dev-db-instance
        Master username: admin <x> Self managed
        Master password: «strong password>
        Confirm password: <strong password> 
        <x> Standared classes (includes m classes)
        Class: db.t2.small <Or feasible one>
        Storage type: General Purpose SSD (gp3)
        Allocated storage: 20GB <Or as needed> <x> Don't connect to an EC2 compute resources
        VPC: <Created VPC>
        DB subnet group: dev-db-subnet-group
        Public access: No
        Existing VPC security groups: database-tier-rds-sg
        ** Rest are as default
    > Create database
    ```
3. Connecting to RDS instance
    ```
    SSH to bastion host > SSH to RDS instance >
    ```
    Then follow the instructions from Github repository

## Setting up presentation tire
1. Create launch template for presentation tier
    ```
    EC2 > Launch templates > Create launch template >
        Launch template name: presentation-tier-launch-template
        Template version description: version 01
        <x> Provide guidance to help me set up a template that I can use with EC2 Auto Scaling
        AMI: Amazon machine image «Free tire eligible>
        Instance type: t2.micro
        Key pair: <Created key pair
        Network: <Created VPC>
        Auto-assign Public IP: Enable
        Security Groups: presentation-tier-ec2-sg
        User data: <Copy user data from Github repository»
    > Create launch template
    ```
2. Creating presentation tire target group
    ```
    EC2 > Target groups > Create target group >
        Choose a target type: ‹x> Instances
        Target group name: presentation-tier-target-group
        Protocol and port: HTTP, 80
        IP address type: <x> IPv4
        VPC: <Created VPC>
        Health checks:
        Protocol: HTTP
        Path: /health
    > Create target group
    ```
3. Creating presentation tier load balancer
    ```
    EC2 > Load balancer > Create Application Load Balancer >
        Name: presentation-tier-alb
        Scheme: Internet-facing
        Load balancer IP address type: IPv4
        VPC: «Created VPC>
        Availability zones: <All avallable zones>
        Subnets: <All public subnets>
        Security groups: presentation-tler-alb-sg
        Listener: HTTP, 80 - presentation-tier-target-group
    > Create load balancer
    ```
4. Create Auto scaling group for presentation tire
    ```
    EC2 > Auto Scaling groups > Create Auto Scaling group >
        Name: presentation-tier-asg
        Launch template: presentation-tier-launch-template
        Launch template version: default
    > Next
        VPC: «Created VPC>
        Subnets: «All public subnets>
    > Next
        Load balancing: Attach to an existing load balancer 
        <x> Choose from your load balancer target groups
        Existing load balancer target group: presentation-tier-target-group 
        <x> No VPC Lattice service
        <x> Turn on Elastic Load Balancing health checks 
        <*> Enable group metrics collection with CloudWatch
    > Next
        Desired capacity: 3
        Min desired capacity: 2
        Max desired capacity: 4
        <x> Target tracking scaling policy
        Scaling policy name: Scaling Tracking Policy
        Average CPU utilization:
        Target value: 50
        Instance wormup: 300 seconds
        Instance maintenance policies: No policy
    > Next > Next > Review > Create Auto Scaling group
    ```
   - Verify hitting to presentation tire load balancer's DNS name and it should create the HTML page we have created erlier.
5. Stress testing the presentation tier (Auto scaling)
   - Open the terminal and connect to the Bastion Host
   - Connect to one of the EC2 instances of presentation tier
   - Install strees package and run stress test
        ```bash
        sudo yum install stress -y 
        stress -cpu 4 -timeout 600
        top
        ```
   - Navigate to the Cloud Watch console and check the alarm. The alarm high should be triggered
   - Navigate to the Auto Scaling group and check the number of instances running. It should increase by one.
6. Creating a Cloud Watch alarm for the presentation tier

## Setting up application tire (The process is similar as presentation tire)
1. Create launch template for the application tire EC2 instances
    ```
    EC2 > Launch templates > Create launch template >
        Launch template name: application-tier-launch-template
        Template version description: version 01
        <*> Provide guidance to help me set up a template that I can use with EC2 Auto Scaling
        AMI: Amazon machine image ‹Free tire eligible>
        Instance type: t2.micro
        Key pair: «Created key pair›
        Security Groups: application-tier-ec2-sg
        User data: «Copy paste from Github Configure Application Tire> #Update db part according to
        your RDS instance
    > Create launch template
    ```
2. Set up terget group that the application tier load balancer will use to Route traffic to the application tier EC2 instances
    ```
    EC2 > Target groups > Create target group >
        Choose a target type: <x> Instances
        Target group name: application-tier-target-group
        Protocol and port: HTTP, 3200 #NodeJs application running port 
        Ip address type: IPv4
        VPC: <Created VPC>
        Health checks:
        Protocol: HTTP
        Path: /health #Health check route configured in application accordingly
    > Next > Create target group
    ```
3. Configure the application tier load balancer to distribute incoming traffic evenly across the application tier EC2 instances
    ```
    EC2 > Load balancers > Create load balancer >
        Name: application-tier-alb
        Scheme: internal
        Load balancer IP address type: IPv4
        VPC: <Created VPC>
        Availability zones: <All available zones>
        Subnets: <All private subnets>
        Security groups: application-tier-alb-sg
        Listeners: HTTP, 80 -> application-tier-target-group
    > Create load balancer
    ```
4. Create autoscaling group to automatically scale out or in based on demand ensuring our application tire is always ready to handle the load
    ```
    EC2 > Auto Scaling groups > Create Auto Scaling group >
        Name: application-tier-asg
        Launch template: application-tier-launch-template
        Launch template version: default
    > Next
        VPC: «Created VPC»
        Subnets: «All private subnets>
    > Next
        Load balancing: Attach to an existing load balancer < Choose from your load balancer target groups
        Existing load balancer target group: application-tier-target-group 
        <x> No VPC Lattice service
        <x> Turn on Elastic Load Balancing health checks
        Health check grace period: 300 seconds <x> Enable group metrics collection with CloudWatch
    > Next
        Desired capacity: 3
        Min desired capacity: 2
        Max desired capacity: 4
        <x> Target tracking scaling policy
        Scaling policy name: Scaling Tracking Policy
        Average CPU utilization:
        Target value: 50
        Instance warmup: 300 seconds
        Instance maintenance policies: No policy
    Next > Next > Review > Create Auto Scaling group
    ```
   - Navigate to ec2 instances and verify the instances are running (Bastion host, 3 ect for presentation tire, and 3 for application tire)
   - Veriry that the NodeJs application up and running correctly
   - To do that, navigate to the Bastion host and connect to one of the application tier EC2 instances and check the nodejs application is running as expected
        ```bash 
        pm2 logs
        ```
## Modify Presentation Tire Launch Template
1. Now the application tire is running and now need to deploy the frontend(React.JS) application to the presentation tier EC2 instances. To do that we need to modify the launch template of the presentation tier
    ```
    EC2 > Launch templates > presentation-tier-launch-template > Modify template >
        Template version description: version 02
        User data: <Copy user data from Github repository> #Update the user data script to include the
    deployment of ReactS application. Also APP_TIER_ALB_URL and SERVER_NAME should be updated accordingly
    > Save changes
    ```
2. Modify the Auto Scaling group to use the modified launch template
    ```
    EC2 > Auto Scaling groups > presentation-tier-asg > Actions > Edit >
        Launch template: presentation-tier-launch-template
        Launch template version: version 02
    > Save changes
    ```
    - Then terminate all three ec2 instances of the presentation tier and wait. New ec2 instances should launch
    - Access the Presentation tire load balancer DNS name and verify the ReactJS application is running as expected
    - Also update some Books to generate backend log activity

## Integrating application logs with CloudWatch
1. Connect to one of the application tire ec2 instances and check the log files
    ``` bash 
    cd react-node-mysql-app/backend/logs/ 
    ls
    cat combined.log
    ```
2. Now integrate the application logs to CloudWatch logs. To do that, create a IAM role to access Application tire ec2 instances allowing them to write logs to CloudWatch 
    ```
    IAM > Roles > Create role >
        Trusted entity type: AWS service
        Service or use case: EC2
        Use case: EC2
    > Next >
        Permissions: CloudWatchLogsFullAccess, CloudWatchAgetntServerPolicy
    > Next >
        Role name: application-tier-cloudwatch-logs-role
        Description: Role to allow application tier ec2 instances to write logs to cloud watch
    > Create role
    ```
3. Next we will create log group in CloudWatch logs where our application logs will be stored
    ```
    CloudWatch > Log groups > Create log group
        Log group name: application-tier-logs
        Retention: Never expire
    > Create log group
    ```
4. Finally we will need to modify our application tier launch template to include these new configurations
    ```
    EC2 > Launch templates > application-tier-launch-template > Modify template >
        Template version description: version 02
        Advanced details:
        IAM instance profile: application-tier-cloudwatch-logs-role
        Detailed CloudWatch monitoring: Enabled
        User data: ‹Copy user data from Github repository that configurs CloudWatchAgent>
    > Save changes
    ```
5. Update the autoscaling group as well for application tier to apply the new launch template
    ```
    EC2 > Auto Scaling groups > application-tier-asg > Actions > Edit >
        Launch template: application-tier-launch-template
        Launch template version: version 02
    > Save changes
    ```
6. To apply the changes terminate all the application tier ec2 instances and wait for new ones to launch
   - Access and verify the application running as expected using presentation tier uri
   - To verify the logs are being capture by CloudWatch, update a book item.
   - Then check the CloudWatch logs
    ```
    CloudWatch > Log groups > application-tier-logs > Log streams > Select any log stream > View log events
    ```
## Creating a CloudFront distribution
1. Create cloud front distribution
   ```
   CloudFront > Distributions > Create
        Origin domain: <Created application loadbalancer>
        Protocol: HTTP only
        Port: 80
        Viewer protocol policy: Redirect HTTP to HTTPS
        Web Application Firewall (WAF): Do not enable security protections
        Price class: Use only north America and Europe
        Alternate domain name:
            josim74.life
            <Alternative if any>
        Custom SSL certificate: <Choose the we configured earlier>
    > Create
## Creating DNS records for CloudFront in Rout53
To ensure that our traffic properly distributed to our cloud front, We will setup DNS records withing the Rout53 hosted zones we established earlier.
1. Create an alias record for the root domain to direct all traffic to the cloud front distribution 
    ```
    Rout53 > Hosted zones > <Domain name> > Create record >
        <Enable> Alias
        Rout traffic to: <Root domain>
    > Create
    ```
2. Create second record for the sub domain
    ```
   Rout53 > Hosted zones > <Domain name> > Create record >
        Record name: www
        <Enable> Alias
        Route traffic to: Alias to Cloudfront distribution
        <Choose to same cloud front distribution>`
    > Create 
    ```
## Testing Application
 - Now we should be able to access our website with root and subdomain
 - Let's create some CRUD operation to our app like - ADD, Delete, Update


        

