# AWS
<details><summary>Create IAM user and add MFA device</summary>
- Create IAM user
    AWS Console > Search: IAM > User > Create user >
        username: it-admin
        <Check> Provide user access to AWS management console
        <Check> I want to create and IAM user
        <Check> Auto generage password
        <Check> User must create a new password at next login
    > Next >
        <Check> Attach policies
        <Check> AdministratorAccess
    > Next > Create user > Download CSV
- Add MFA device to it-admin
- Create account alias
    AWS console > IAM > AWS account > Create >
        Prefered alias: it-admin
    > Save changes
    **Create user csv again and download
    ** Update the password on next login
<p>Prefered
</p>
</details>

<details><summary>Set AWS billing alarm</summary>
AWS console > Billing dashboard > Billing preference >
    <Check> PDF invoice delivered by email
> Alert preference >
    <Check> Recieve AWS freetier alerts. <put email address>
    <Check> Recieve cloud watch billing alert

** Set region: us-east-1a (N.verginia)
AWS console > cloud watch > Alarms > All alarms > Create alarm > Select metric > billing > Total estimated charge
    <Check> USD
    > Select metric >
        Threshold value: 5 USD
> Next >
    <Check> In alarm
    <Check> SNS topic: Create new topic
        Create new topic: Monitoring team
        Email endpoints: <email>
    > Create topic
    ** Topic will exist in the N.vergini region
> Next >
    Alarm name: AWS billing alarm
> Next > Create
** Then confirm subscription form email
** Finally check the status from alarm 'OK' expected
<p>
</p>
</details>

<details><summary>Create a public certificate (SSL) from aws</summary>
AWS Console > ACM > Certificate manager > Certificates > Request certificate >
    <Check> Request a public certificate
    Domain name: *.josim74.life
    Validation method: DNS validation
    Key algorithom: RSA
    tag: name: josim74.life
> Create
- Collect CName and CValue from the created certificate
- Add to the domain as a CName record
- Remove <.josim74.life> from the end of the certificate CName
- Remove<.> from the end of the certificate CValue
** Status should be from pending to issued in 48 hours in AWS certificate
<p>
</p>
</details>

<details><summary>Create security group</summary>
EC2 > Security group > Create security gorup >
    Security group name: vprofile-elb-sg
    Description: Security group for load balanching
    Vpc: <Default or Own created>
    Inbound rules:  
        HTTP - TCP - 80 - Anywhere - Allows request from anywhere
        HTTPS - TCP - 443 - Anywhere - Allows request from anywhere
> Save

EC2 > Security group > Create security group >
    Security group name: vprofile-app-sg
    Description: Security group for app/tomcate server
    Vpc: <Default vpc or Own created>
    Inbound rules:
        Custom TCP - TCP - 8080 - Custom <load balance security group> - Allows request from load balancer
        Custom TCP - TCP - 8080 - MY IP - Allows request form my PC to troubleshoot
        Custom TCP - TCP - 22 - MY IP - Allows SSH access for troubleshooting purpose

> Save

EC2 > Security group > Create security group >
    Security group name: vprofile-backend-sg
    Description: Security group for backend services
    Vpc: <Default vpc or Own created>
    Inbound rules:
        MYSQL/Aurora - TCP - 3306 - Custom <vprofile-app-sg> - Allow traffic from app/tomcat server
        Custom TCP - TCP - 5612 - Custom <vprofile-app-sg> - Allow traffic from app/tomcat server
        Custom TCP - TCP - 22 - MY IP - Allow SSH access for troubleshooting purpose
        All traffic - All - Custom <vprofile-backend-sg (self)> - Allow traffice to access backend services each other
> Save
<p>
</p>
</details>

<details><summary>Create login key pair</summary>
EC2 > Key pair > Create pair >
    Name: vprofile-prod-key
    <Check> Pem
> Create [**Download and save somewhere]
<p>
</p>
</details>

<details><summary>Create instances</summary>
**Clone source code. The branch is AwsLiftAndShift
- DB instance:
    EC2 > instances > Launch an instance >
        Name: vprofile-db01
        Additional tag:
            project: vprofile
        Amazon machine image: Almalinux os 9 (x86, x64)
        Instance type: t2.micro
        Key pair: vprofile-prod-key (Previously creted)
        Vpc: <Default or Own created>
        Security group: vprofile-backend-sg
        User data: <Scrift if any>
    > Launch instance
    Instance verification:
        - SSH login to DB instance
        - Verify user data: curl <user data url>
        - Verify db service: systemctl status mariadb
        - Check db: mysql -u admin -padmin123 accounts;
                    show tables;

- Memcached instance:
    EC2 > instances > Launch an instance >
        Name: vprofile-mc01
        Additional tag:
            project: vprofile
        Amazon machine image: Almalinux os 9 (x86, x64)
        Instance type: t2.micro
        Key pair: vprofile-prod-key (Previously creted)
        Vpc: <Default or Own created>
        Security group: vprofile-backend-sg
        User data: <Scrift if any>
    > Launch instance
    Instance verification:
        - SSH login to Memcached instance
        - Verify user data: curl <user data url>
        - Verify memcached service: ss -tunlp | grep 11211

- RabbitMQ instance:
    EC2 > instances > Launch an instance >
        Name: vprofile-rmq01
        Additional tag:
            project: vprofile
        Amazon machine image: Almalinux os 9 (x86, x64)
        Instance type: t2.micro
        Key pair: vprofile-prod-key (Previously creted)
        Vpc: <Default or Own created>
        Security group: vprofile-backend-sg
        User data: <Scrift if any>
    > Launch instance
    Instance verification:
        - SSH login to RabbitMQ instance
        - Verify user data: curl <user data url>
        - Verify RabbitMQ service: systemctl status rabbitmq-server

- Tomcat instance:
    EC2 > instances > Launch an instance >
        Name: vprofile-app01
        Additional tag:
            project: vprofile
        Amazon machine image: Ubuntu
        Instance type: t2.micro
        Key pair: vprofile-prod-key (Previously creted)
        Vpc: <Default or Own created>
        Security group: vprofile-app-sg
        User data: <Scrift if any>
    > Launch instance
    Instance verification:
        - SSH login to Tomcat instance
        - Verify user data: curl <user data url>
        - Verify tomcat9 service: systemctl status tomcat9
        - Verify tomcat hote directory: ls /var/lib/tomcat9
</details>

<details><summary>Rout53 for private hosted zone</summary>
    - Create hosted zone
        Rout53 > Hosted zones > Create hosted zone
            Domain name: vprofile.in
            region: us-east-1
            Vpc: <Default or Own created>
    - Create record
        Rout53 > Hosted zones > vprofile.in > Create record
            Routing policy: Simple rounting
        > Next > 
            Record name: db01 <vprofile.in>
            Record type: A-Routs traffic to an IPv4 and ...
            Value/Rout traffic to: <vprofile-db01 private IP>
            TTLS: 300
        > Define simple record > Create record
    ** Samy way for mc01 and rmq01
    ** We need only those three to connect through application.properties file
</details>

<details><summary>Build and Deploy Artifact</summary>
    - Open gitbash in VSCode terminal
        VSCode > Ctrl + Shift + P
            Search: Default profile
            <Select> Gitbash
    - Modify application.properties
        -Colen source code (Vprofile project in github)
        - Checkout to the branch AwsLiftAndShift
        - Open application.properties
            db01:3306 => db01.vprofile.in:3306
            mc01 => mc01.vprofile.in
            rmq01 => rmc01.vprofile.in
        > Save the file
    - Build artifact
        - Change directory where pom.xml file exist
        - Install maven 3.xx version and JDK 11
        - Check maven version: mvn -version
        - Install awscli: sudo apt update && sudo apt install awscli
        - Build artifact: mvn install
        - Once build finished. You will see target directory
        - Collect artifact and upload to S3 bucket
    - Upload artifact to S3 bucket
        - Create IAM user
            IAM > Users > Create user
            Username: s3admin
        > Next >
            <Check> Attach policies directory
            <Check> AmazonS3FullAccess
        > Next > Create user
    - Create access keys
        IAM > User > s3admin > Create key
            <Check> Commandline interface
            <Check> I understand above recommendations
        > Create user   [** Store the key somewhere]
    - Uplaod artifact to S3 bucket
        - Configure aws cli in local PC
            $ aws confgure
            $ Access key ID:
            $ Secret access key:
            $ Region should be us-east-1
        - Create s3 bucket
            $ aws s3 mb s3://josim74-vpro-arts  [** Must be unique]
            $ aws s3 cp target/vprofile-v2.war s3://josim74-vpro-arts/
            [** You should be able to see the s3 bucket in bucket list in aws console]
    - Download artifact to tomcat server
        - We can use s3admin to do this but it is better to use IAM role
        - Create IAM role
            IAM > Roles > Create role
                <Check> AWS service
                <Check> EC2
            > Next >
                <Check> Amazons3FullAccess
            > Next >
                name: josim74-vprof-s3
            > Create role
        - Attach the role with tomcat server from action
        - SSH to tomcat server
            $ sudo apt update
            $ sudo apt install
            $ sudo apt install awscli -y
            $ aws s3 ls
            $ aws s3 cp s3://josim74-vprof-arts/vprofile-v2.war /temp
            $ systemctl stop tomcat9
            $ rm -rf /var/lib/tomcat9/webapps/ROOT
            $ cp /temp/vprofile-v2.war /var/lib/tomcat9/webapps/ROOT.war
            $ systemctl start tomcat9
            $ ls /var/lib/tomcat9/webapps/ROOT/
            [** You should see ROOT and ROOT.war also you can verify the application.properties file]
</details>
<details><summary>Create and configure load balancer</summary>
    - Create target group
        EC2 > Target groups > Create target group >
            Type: Instance
            Target group name: vprofile-app-tg
            Protocol: port
            HTTP: 80
            VPC: Default or Own created
            Health check: /login
            Advanced health check:
                <Check> Override
                8080
                Health threshold: 3
        > Next >
            Available instance: vprofile-app01
            Port for the selected instance: 8080
        > Create target group
    - Create load balancer
        EC2 > Load balancer > Create load balancer
            <Select> Application load balancer
        > Create >
            Load balancer name: vprofile-prod-elb
            <Check> Internet facing
            IP address type: IPv4
            VPC: Default or own created
            Mappings: us-east-1 or select all   [** Should select at least two]
            Security group: vprofile-elb-sg
            Listener: 
                HTTP - 80 - vprofile-app-tg
                HTTPS - 443 - vprofile-app-tg
            Security listener settings:
                Security policy: ELBsecuritypolicy-2016
                Default SSL: <Select> from ACM (josim74.life)
        > Create load balancer
    - Add CName record to the domain
        <CName> Host: vprofile, Points to: <ELB-DNS-Name>
    - Verify status and check the URL. Like vprofile.josim74.life
</details>
<details><summary>Auto scaling group</summary>
    - Create AMI of the tomcat server
        EC2 > Instances > vprofile-app01 > action > image > Create image >
            Image name: vprofile-app-image
    - Create launch configurations
        EC2 > Launch configurations > Create launch configuration >
            Name: vprofile-app-lc
            AMI: vprofile-app-image     [** Previously create image]
            Instance type: t2.micro
            AMI instance profile/IAM role: vprofile-artifact-storage-role
            <Check> Enable EC2 instance detail monitoring
            Security group: vprofile-app-sg
            Desired capacity: 2
            Minimum: 2
            Maximum: 5
            Sailing policies:
                <Check> Target tracking scaling policy
                Scaling policy name: Target tracking policy
                Matric type: Average CPU utilization
                Target value: 50
        > Next >
            Add notification: <Assign previously created if any or create new>
            tag:
                Name: vprofile-app
                Project: vprofile
        > Create auto scaling group
    - To validate, hit the URL: vprofile.josim74.life
</details>