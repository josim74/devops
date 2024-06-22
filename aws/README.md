# AWS Setup Instructions

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
