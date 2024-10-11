# AWS Setup Instructions
This directory will contain all aws learnings and practices. For project based work (check out the ci_cd directory).

<details>
  <summary>Create IAM User and Add MFA Device</summary>

## Step 1: Create IAM User

1. Open the **AWS Management Console**.
2. In the search bar, type **IAM** and select **IAM** from the results.
3. Navigate to **Users** > **Create User**.
4. Enter the username: `it-admin`.
5. Check the following options:
    - **Provide user access to AWS management console**
    - **I want to create an IAM user**
    - **Auto-generate password**
    - **User must create a new password at next login**
6. Click **Next**.
7. Attach the required policies by checking **AdministratorAccess**.
8. Click **Next** > **Create User**.
9. Download the CSV file containing user credentials.

## Step 2: Add MFA Device to `it-admin`

1. Go to the **IAM** section in the AWS Console.
2. Select the user `it-admin`.
3. In the user details, select the **Security credentials** tab.
4. Under **Multi-factor authentication (MFA)**, click **Manage**.
5. Follow the prompts to assign an MFA device to the user.

## Step 3: Create Account Alias

1. In the **IAM** section of the AWS Console, select **AWS Account Settings**.
2. Click **Create** next to **Account Alias**.
3. Enter the preferred alias: `it-admin`.
4. Click **Save changes**.

## Final Steps

- Download the user CSV file again after creating the account alias.
- Ensure that `it-admin` updates the password at the next login.

</details>

<details>
  <summary>Set AWS Billing Alarm</summary>

## Step 1: Configure Billing Preferences

1. Open the **AWS Management Console**.
2. Navigate to the **Billing Dashboard**.
3. Go to **Billing Preferences**.
4. Check the following options:
    - **PDF invoice delivered by email**
    - **Receive AWS Free Tier alerts** and enter your email address.
    - **Receive CloudWatch billing alerts**.

## Step 2: Set Region to us-east-1a (N. Virginia)

1. Ensure your region is set to **us-east-1a (N. Virginia)**.

## Step 3: Create CloudWatch Billing Alarm

1. In the AWS Console, navigate to **CloudWatch**.
2. Go to **Alarms** > **All Alarms** > **Create Alarm**.
3. Select **Metric** > **Billing** > **Total Estimated Charge**.
4. Choose the following:
    - **Unit**: USD
5. Click **Select Metric**.
6. Set the **Threshold Value** to **5 USD**.

## Step 4: Configure Alarm Actions

1. Click **Next**.
2. Check **In alarm**.
3. Under **SNS topic**, select **Create new topic**:
    - **Topic Name**: Monitoring team
    - **Email endpoints**: Enter your email address
4. Click **Create Topic**.
    - Note: The topic will exist in the N. Virginia region.

## Step 5: Finalize Alarm Settings

1. Click **Next**.
2. Set the **Alarm Name** to **AWS Billing Alarm**.
3. Click **Next** > **Create Alarm**.

## Final Steps

- Confirm the subscription from the email you receive.
- Check the status of the alarm, which should show 'OK' as expected.

</details>

<details>
  <summary>Create a Public Certificate (SSL) from AWS</summary>

## Step 1: Request a Public Certificate

1. Open the **AWS Management Console**.
2. Navigate to **ACM (AWS Certificate Manager)**.
3. Go to **Certificate Manager** > **Certificates** > **Request Certificate**.
4. Check the following option:
    - **Request a public certificate**
5. Enter the **Domain Name**: `*.josim74.life`.
6. Choose the **Validation Method**: DNS validation.
7. Set the **Key Algorithm**: RSA.
8. Add a **Tag**:
    - **Name**: josim74.life
9. Click **Create**.

## Step 2: Configure DNS Validation

1. Collect the **CNAME** and **CValue** from the created certificate.
2. Add these values to your domain's DNS settings as a **CNAME record**:
    - **CName Record**: Remove `.josim74.life` from the end.
    - **CValue**: Remove `.` from the end.

## Step 3: Verify Certificate Status

1. The certificate status should change from **Pending** to **Issued** within 48 hours in AWS Certificate Manager.

</details>

<details>
  <summary>Create Security Groups</summary>

## Step 1: Create Security Group for Load Balancing

1. Open the **AWS Management Console**.
2. Navigate to **EC2** > **Security Groups** > **Create Security Group**.
3. Set the following:
    - **Security Group Name**: `vprofile-elb-sg`
    - **Description**: Security group for load balancing
    - **VPC**: Select the default VPC or your own created VPC
4. Configure **Inbound Rules**:
    - **HTTP** - **TCP** - **80** - **Anywhere** - Allows requests from anywhere
    - **HTTPS** - **TCP** - **443** - **Anywhere** - Allows requests from anywhere
5. Click **Save**.

## Step 2: Create Security Group for Application/Tomcat Server

1. Navigate to **EC2** > **Security Groups** > **Create Security Group**.
2. Set the following:
    - **Security Group Name**: `vprofile-app-sg`
    - **Description**: Security group for app/Tomcat server
    - **VPC**: Select the default VPC or your own created VPC
3. Configure **Inbound Rules**:
    - **Custom TCP** - **TCP** - **8080** - **Custom** (load balancer security group) - Allows requests from the load balancer
    - **Custom TCP** - **TCP** - **8080** - **My IP** - Allows requests from your PC for troubleshooting
    - **Custom TCP** - **TCP** - **22** - **My IP** - Allows SSH access for troubleshooting purposes
4. Click **Save**.

## Step 3: Create Security Group for Backend Services

1. Navigate to **EC2** > **Security Groups** > **Create Security Group**.
2. Set the following:
    - **Security Group Name**: `vprofile-backend-sg`
    - **Description**: Security group for backend services
    - **VPC**: Select the default VPC or your own created VPC
3. Configure **Inbound Rules**:
    - **MYSQL/Aurora** - **TCP** - **3306** - **Custom** (`vprofile-app-sg`) - Allows traffic from app/Tomcat server
    - **Custom TCP** - **TCP** - **5612** - **Custom** (`vprofile-app-sg`) - Allows traffic from app/Tomcat server
    - **Custom TCP** - **TCP** - **22** - **My IP** - Allows SSH access for troubleshooting purposes
    - **All Traffic** - **All** - **Custom** (`vprofile-backend-sg (self)`) - Allows traffic between backend services
4. Click **Save**.

</details>

<details>
  <summary>Create Login Key Pair</summary>

## Step 1: Create Key Pair

1. Open the **AWS Management Console**.
2. Navigate to **EC2** > **Key Pairs** > **Create Key Pair**.
3. Set the following:
    - **Name**: `vprofile-prod-key`
    - **File format**: Check **PEM**
4. Click **Create Key Pair**.

## Final Step

- **Download and save** the key pair file (`.pem`) in a secure location.

</details>

<details>
  <summary>Create Instances</summary>

## Step 1: Clone Source Code

- Ensure the branch is `AwsLiftAndShift`.

## Step 2: Create DB Instance

1. Open the **AWS Management Console**.
2. Navigate to **EC2** > **Instances** > **Launch an Instance**.
3. Configure the instance:
    - **Name**: `vprofile-db01`
    - **Additional Tag**:
        - **Key**: `project`
        - **Value**: `vprofile`
    - **Amazon Machine Image**: AlmaLinux OS 9 (x86, x64)
    - **Instance Type**: `t2.micro`
    - **Key Pair**: `vprofile-prod-key` (previously created)
    - **VPC**: Select the default VPC or your own created VPC
    - **Security Group**: `vprofile-backend-sg`
    - **User Data**: `<script if any>`
4. Click **Launch Instance**.

### Instance Verification:

- SSH login to the DB instance.
- Verify user data: `curl <user data url>`.
- Verify DB service: `systemctl status mariadb`.
- Check DB:
  ```bash
  mysql -u admin -padmin123 accounts
  show tables;

## Step 3: Create Memcached Instance

1. Navigate to **EC2** > **Instances** > **Launch an Instance**.
2. Configure the instance:
    - **Name**: `vprofile-mc01`
    - **Additional Tag**:
        - **Key**: `project`
        - **Value**: `vprofile`
    - **Amazon Machine Image**: AlmaLinux OS 9 (x86, x64)
    - **Instance Type**: `t2.micro`
    - **Key Pair**: `vprofile-prod-key` (previously created)
    - **VPC**: Select the default VPC or your own created VPC
    - **Security Group**: `vprofile-backend-sg`
    - **User Data**: `<script if any>`
3. Click **Launch Instance**.

### Instance Verification:

- SSH login to the Memcached instance.
- Verify user data: `curl <user data url>`.
- Verify Memcached service: `ss -tunlp | grep 11211`.

## Step 4: Create RabbitMQ Instance

1. Navigate to **EC2** > **Instances** > **Launch an Instance**.
2. Configure the instance:
    - **Name**: `vprofile-rmq01`
    - **Additional Tag**:
        - **Key**: `project`
        - **Value**: `vprofile`
    - **Amazon Machine Image**: AlmaLinux OS 9 (x86, x64)
    - **Instance Type**: `t2.micro`
    - **Key Pair**: `vprofile-prod-key` (previously created)
    - **VPC**: Select the default VPC or your own created VPC
    - **Security Group**: `vprofile-backend-sg`
    - **User Data**: `<script if any>`
3. Click **Launch Instance**.

### Instance Verification:

- SSH login to the RabbitMQ instance.
- Verify user data: `curl <user data url>`.
- Verify RabbitMQ service: `systemctl status rabbitmq-server`.

## Step 5: Create Tomcat Instance

1. Navigate to **EC2** > **Instances** > **Launch an Instance**.
2. Configure the instance:
    - **Name**: `vprofile-app01`
    - **Additional Tag**:
        - **Key**: `project`
        - **Value**: `vprofile`
    - **Amazon Machine Image**: Ubuntu
    - **Instance Type**: `t2.micro`
    - **Key Pair**: `vprofile-prod-key` (previously created)
    - **VPC**: Select the default VPC or your own created VPC
    - **Security Group**: `vprofile-app-sg`
    - **User Data**: `<script if any>`
3. Click **Launch Instance**.

### Instance Verification:

- SSH login to the Tomcat instance.
- Verify user data: `curl <user data url>`.
- Verify Tomcat9 service: `systemctl status tomcat9`.
- Verify Tomcat home directory: `ls /var/lib/tomcat9`.
</details>

<details>
  <summary>Rout53 for Private Hosted Zone</summary>

## Step 1: Create Hosted Zone

1. Navigate to **Route 53** > **Hosted zones** > **Create hosted zone**.
2. Configure the hosted zone:
    - **Domain name**: `vprofile.in`
    - **Region**: `us-east-1`
    - **VPC**: Select the default VPC or your own created VPC.
3. Click **Create hosted zone**.

## Step 2: Create Records

1. Navigate to **Route 53** > **Hosted zones** > `vprofile.in` > **Create record**.
2. Configure the record:
    - **Routing policy**: Simple routing
    - **Record name**: `db01.vprofile.in`
    - **Record type**: A - Routes traffic to an IPv4 address and some AWS resources
    - **Value/Routing traffic to**: `<vprofile-db01 private IP>`
    - **TTL (Time to Live)**: 300 (seconds)
3. Click **Define simple record** > **Create record**.

### Repeat the same steps for `mc01` and `rmq01`:
- Create records for `mc01.vprofile.in` and `rmq01.vprofile.in` similarly.

## Notes:
- Only these three instances (`db01`, `mc01`, `rmq01`) need to be configured to connect through the `application.properties` file.
</details>

<details>
  <summary>Build and Deploy Artifact</summary>

## Step 1: Open Gitbash in VSCode Terminal

1. Open VSCode.
2. Press **Ctrl + Shift + P**.
3. Search for: **Default profile**.
4. Select: **Gitbash**.

## Step 2: Modify `application.properties`

- Clone source code (Vprofile project from GitHub).
- Checkout to the branch `AwsLiftAndShift`.
- Open `application.properties`.
  - **Update:**
    - db01:3306 => db01.vprofile.in:3306
    - mc01 => mc01.vprofile.in
    - rmq01 => rmq01.vprofile.in
    - Save the file.

## Step 3: Build Artifact

- Change directory where `pom.xml` file exists.
- Install Maven 3.xx version and JDK 11.
- Check Maven version: `mvn -version`.
- Install AWS CLI: `sudo apt update && sudo apt install awscli`.
- Build artifact: `mvn install`.
- Once build finished, you will see `target` directory.
- Collect artifact and upload to S3 bucket.

## Step 4: Upload Artifact to S3 Bucket

1. Create IAM user:
 - Navigate to **IAM** > **Users** > **Create user**.
 - Username: `s3admin`.
 - Next > Attach policies:
   - AmazonS3FullAccess.
 - Next > Create user.

2. Create access keys:
 - IAM > User > `s3admin` > Create key.
 - Check: Command-line interface.
 - Check: I understand above recommendations.
 - Create user. [** Store the key somewhere]

3. Upload artifact to S3 bucket:
 - Configure AWS CLI in local PC:
   ```
   $ aws configure
   $ Access key ID:
   $ Secret access key:
   $ Region should be us-east-1
   ```
 - Create S3 bucket:
   ```
   $ aws s3 mb s3://josim74-vpro-arts  [** Must be unique]
   $ aws s3 cp target/vprofile-v2.war s3://josim74-vpro-arts/
   [** You should be able to see the S3 bucket in the bucket list in AWS console]

## Step 5: Download Artifact to Tomcat Server

1. Use IAM role instead of `s3admin`:
 - Create IAM role:
   - Navigate to **IAM** > **Roles** > **Create role**.
   - Check: AWS service.
   - Check: EC2.
   - Next > Attach policies:
     - AmazonS3FullAccess.
   - Next > Name: `josim74-vprof-s3`.
   - Create role.
 - Attach the role with Tomcat server from actions.

2. SSH to Tomcat server:
  ```
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
  ```
**You should see ROOT and ROOT.war also you can verify the application.properties file**
</details>
<details>
  <summary>Create and Configure Load Balancer</summary>

## Step 1: Create Target Group

1. Navigate to **EC2** > **Target groups** > **Create target group**.
2. Configure the target group:
    - **Type**: Instance
    - **Target group name**: `vprofile-app-tg`
    - **Protocol**: HTTP
    - **Port**: 80
    - **VPC**: Select the default VPC or your own created VPC
    - **Health check**: `/login`
    - **Advanced health check**:
        - Check: Override
        - Port: 8080
        - Health threshold: 3
3. Next > 
    - Available instance: `vprofile-app01`
    - Port for the selected instance: 8080
4. Click **Create target group**.

## Step 2: Create Load Balancer

1. Navigate to **EC2** > **Load balancer** > **Create load balancer**.
2. Select: **Application load balancer** > **Create**.
3. Configure the load balancer:
    - **Load balancer name**: `vprofile-prod-elb`
    - Check: Internet facing
    - **IP address type**: IPv4
    - **VPC**: Select the default VPC or your own created VPC
    - **Availability Zones**: Select at least two zones in `us-east-1` or select all available
    - **Security group**: `vprofile-elb-sg`
    - **Listener**:
        - HTTP - 80 - `vprofile-app-tg`
        - HTTPS - 443 - `vprofile-app-tg`
    - **Security listener settings**:
        - Security policy: `ELBsecuritypolicy-2016`
        - Default SSL: Select from ACM (`josim74.life`)
4. Click **Create load balancer**.

## Step 3: Add CName Record to the Domain

- Add CName record:
  - Host: `vprofile`
  - Points to: `<ELB-DNS-Name>` (obtained from the load balancer creation)

## Step 4: Verify Status and Check the URL

- Verify status and check the URL, e.g., `vprofile.josim74.life`.

</details>

<details>
  <summary>Auto Scaling Group</summary>

## Step 1: Create AMI of the Tomcat Server

1. Navigate to **EC2** > **Instances** > `vprofile-app01` > **Actions** > **Image** > **Create image**.
2. Configure the image:
    - **Image name**: `vprofile-app-image`.
3. Click **Create image**.

## Step 2: Create Launch Configuration

1. Navigate to **EC2** > **Launch configurations** > **Create launch configuration**.
2. Configure the launch configuration:
    - **Name**: `vprofile-app-lc`.
    - **AMI**: `vprofile-app-image` (previously created).
    - **Instance type**: `t2.micro`.
    - **AMI instance profile/IAM role**: `vprofile-artifact-storage-role`.
    - Check: Enable EC2 instance detail monitoring.
    - **Security group**: `vprofile-app-sg`.
    - **Desired capacity**: 2
    - **Minimum**: 2
    - **Maximum**: 5
    - **Scaling policies**:
        - Check: Target tracking scaling policy.
        - **Scaling policy name**: `Target tracking policy`.
        - **Metric type**: Average CPU utilization.
        - **Target value**: 50.
3. Click **Next**.
4. Add notifications if required (assign previously created or create new).
5. Tags:
    - Name: `vprofile-app`.
    - Project: `vprofile`.
6. Click **Create auto scaling group**.

## Step 3: Validate

- To validate, access the URL: `vprofile.josim74.life`.

</details>