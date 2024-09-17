# Github action for CI/CD

## Github setup
    - Generate ssh key and add to github account
        ssh-keygen      [Enter file in which to save the key: <github username> (optional)]
        > Enter > Enter
        - Copy the public key (~/.ssh/<github username>.pub) and add to github account
        - Verify the authentication using private key
            ssh -i ~/.ssh/<github username> -T git@github.com
    - Fork the github repo with all branches from 'github.com/hkhcoder/hprofile'
    - Clone git repo for specific account or key
        export GIT_SSH_COMMAND="ssh -i ~/.ssh/<github username>"    [Private key]
        git clone <ssh url of the repo>
        unset GIT_SSH_COMMAND
    - Set specific key for a specific repo (local)
        - cd to local repo
            git config core.sshCommand "ssh -i ~/.ssh/<github user> -F /dev/null"
            cat .git/config     [to verify]
        - Also set username and email
            git config user.name <github username>
            git config user.email <github email>
            cat .git/config     [Verify the config]
        - Commit and push
    - Create a new demo workflow and test in github actions
        .github/workflows/main.yml
            ```
            name: Hprofile actions
            on: workflow_dispatch
            jobs:
                Testing:
                    runs-on: ubuntu-latest
                    steps:
                        - name: Code checkout
                          uses: actions/checkout@4
                        
                        - name: Maven test
                          run: mvn test

                        - name: Checkstyle
                          runn: mvn checkstyle:checkstyle
            ```
        - Commit and push
    - Test the job running from Actions tab in github repo
## Sonarcloud setup
    - Login with github account
    - Create organization and a project under that
        Click on '+' symbol > Create new organization > Create ann organization mannually >
            Name: hprofile
            key: hprofile21
            <x> Free plan
        > Create organization > Analyze new project >
            Organization: hprofile
            Display name: actions-code
            Project key: action-code
            <x> Public
        > Next >
            The new code for this project will be based on:
                <x> Previous version
        > Create project > My projects      [List will be visible here]
    - Get the login token
        Account > My account > security > 
            Token Name: github-actions 
        > Generate token > *Save the token somewhere
## Github Actions secret store
    - Store some variables in github actions secret
        SONAR_URL = "https://sonarclout.io"
        SONAR_TOKEN = "<Token>"
        SONAR_ORGANIZATION = "hprofile21"   [organization key name]
        SONAR_PROJECT_KEY = "actions-code"
## Change workflow to mache the Sonarqube requirements
    - Setup java 11 to default (sonar-scanner requirements as of 5.x) in actions step
        - name: Set java 11
          uses: actions/setup-java@3
          with:
            descriptions: 'teurin'
            java-version: '11'
    - Setup sonar scanner in actions step
        - name: Setup Sonarqube
          uses: warchant/setup-sonar-scanner@7
    - Run sonar-scanner in actions step
        - name: Sonarqube scan
          run: sonar-scanner
            -Dsonar.host.url=${{ secrets.SONAR_URL}}
            -Dsonar.login=${{secrets.SONAR_TOKEN}}
            -Dsonar.projectKey=${{secrets.SONAR_PROJECT_KEY}}
            -Dsonar.source=src/
            -Dsonar.junit.reqortsPath=target/surefire=reports/
            -Dsonar.jacoco.reportsPath=target/jacoco.xxec
            -Dsonar.checkstyle.reportsPaths=target/checkstyle-result.xml
            -Dsonar.java.binarites=target/test-classes/com/visualpathit/account
        - Commit and push the workflow
    - Run the job and check the sonarcloud project once it is success
## ADD a custom quality gate to sonar project
    - Create a quality gate
        Sonarcloud > <organization> > Quality gates > Create
            Name: actionsQG
        > Save Add conditions >
            Where: <x> On overall code
            Quality gate failes when: Bugs
            value: 30
        > Add condition
    - Add to the project
        My projects > actions-code > Administration > Auality gate >
            Quality gate: <select> actionQG
    - Check the quality gate status
        - Add step to actions workflow
            - name: Sonarqube quality gate check
              id: sonarqube-quality-gate-check
              uses: sonarsource/sonarqube-quality-gate-actions@master
              timeout-minutes: 5
              env:
                SONAR_TOKEN: ${{secrets.SONAR_TOKEN}}
                SONAR_HOST_URL: ${{secrets.SONAR_HOST_URL}}
        - Commit and push
    - Run the job and check the results     [it should fail according to enw quality gate threshold value (30)]
## AWS IAM, ECR and ECS
    - Create iam user with ECR and eECS policies
        IAM > Users > Create user >
            User name: git-actions
        > Next >
            Permissions options: <x> Attach policies directly
            Permissions policies:
                <x> AmazonEC2ContainerRegistryFullAccess
                <x> AmmazonECS_FullAccess
        > Next > Create user > Security credentials > Create access key
            <x> Command line interface
            <x> I understand the above recommendations...
        > Next > Create access key > Download .csv file
        - Save the .csv file somewhere
    - Crate ECR repository creation
        ECR > Repositories > Create repository
            Visibility: <x> Private
            Repository name: action-app
        > Create repository > actions-app > View push commands
    - Configure RDS
        RDS > Create database
            Chose a database creation method: <x> Standared create
            <x> Mysql
            Engine version: 8.0.33
            Templates: <x> Free tiere
            DB instance identifier: vpro-app-actions
            Master username: admin
            <x> Auto generate a password
            Vpc: Default
            Vpc security group: <x> Create new
                New vpc security group name: vpro-app-rds-actions-sg
                Inbound rules:
                    Mysql/Aurora - TCP - 3066 - Custom
                    Custom TCP - TCP - 3306 - Custom - Anywhere     [Must be deleted after testing from temp instance]
                Initial database name: accounts
    - Create database > View credentails details >
        - Copy the password and save somewhere with user 'admin'
        - Verify the RDS db on a temp ec2 instance
            EC2 > Launch instance > 
                Name: mysql-client
                IAM: Ubuntu
                Key pair: <x> Create new key pair
                key pair name: mysql-client-key
                key pair type: <x> RSA
                Private key file format: <x> .pem
                Vpc: Default
                Firewall (security group): <x> Create security group
                    Security group name: mysql-client-sg
                    Inbound rules:
                        SSH - TCP - 22 - Anywhere
            > Launch instance
                - SSH to the instance 'mysql-client'
                - Install mysql-client
                    sudo -i
                    apt update && install mysql-client -y
                - Create db, import tables and verify
                    mysql -h <rds endpoint> -u admin -p<password> accounts
                    mysql -h <rds endpoint> -u admin -p<password> accounts < <db_backup.sql path>
                    mysql -h <rds endpoint> -u admin -p<password> accounts
                    show tables
                - Terminate the instance once verification success
    - Add required info to actions secret in github
        AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY
        AWS_ACCOUNT_ID
        REGISTRY    [ID to till .com]
        RDS_USER
        RDS_ENDPOINT
## Docker build and publish
    - Login on existing docker file
        Branch: main
        Dockerfile
    - Update the actions workflow file by adding new job
        - Also add env section right after workflow dispatch
        ```
        on: workflow_dispatch
        env:
        AWS_REGION: us-east-1
            .
            .
            .
        BUILD_AND_PUBLISH:
            needs: Testing
            runs-on: ubuntu-latest
            steps:
            - name: Code checkout
                uses: actions/checkout@v4

            - name: Update application.properties file
                run: |
                sed -i "s/^jdbc.username.*$/jdbc.username\=${{ secrets.RDS_USER }}/" src/main/resources/application.properties
                sed -i "s/^jdbc.password.*$/jdbc.password\=${{ secrets.RDS_PASS }}/" src/main/resources/application.properties
                sed -i "s/db01/${{ secrets.RDS_ENDPOINT }}/" src/main/resources/application.properties

            - name: Build & Upload image to ECR
                uses: appleboy/docker-ecr-action@master
                with:
                access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
                secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
                registry: ${{ secrets.REGISTRY }}
                repo: actapp
                region: ${{ env.AWS_REGION }}
                tags: latest,${{ github.run_number }}
                daemon_off: false
                dockerfile: ./Dockerfile
                context: ./
        ```
        - Commit and push
## ECS Setup
    - Create ECS cluster
        ECS > Cluster > Create cluster > 
            Cluster name: vpro-app-applications
            Default namespace: vpro-app-actions
            <x> AWS Fargate (server less)
            Tag:
                name: vpro-app-actions
        > Create
    - Create new tasks defination
        ECS > Task definations > Create new task deminations >
            Task defination family: vpro-app-actions-tdf
            <AWS> Fagrate
            OS: Linux/x86-64
            CPU: 1 vcpu
            Memory: 2GB
            Task execution role: <Select> Crate new role
            Container details:
                Name: vpro-app
                Image url: <ECR Repo URL>
                Container port: 8080
        > Create
    - Update task execution role
        ECS > Task definitions > vpro-app-actions-tdf > Revision 1 > Containers > ecsTaskExecutionRole > Add vermissions > Attach policies >
            <x> CloudWatchLogsFullAccess
        > Add permissions

    - Create service
        ECS > Cluster > vpro-app-action > Services > Create >
            Existing cluster: <Select> vpro-app-action
            Compute options: <x> Capacity provide strategy
            <x> Use custom (Advanced)
            Capacity provider: FARGATE
            Deployment configuration:
                Application type: <x> Service
                Family: <Select> vpro-app-action-tdf
                Service name: vpro-action-svc
                Service type: Replica
                Desire tasks: 1
                <x> Polling update
                Deployment failor:
                    <Uncheck> User the Amazon ECS deployment  circuit break     [For initially; Later it will be checked]
                Vpc: Default
                Subnet: All
                <x> Create new security group
                    Security group name: vpro-app-action-svc-sg
                    Description: vpro-app-action-svc-sg
                    Inbound rules:
                        HTTP - TCP - 80 - Anywhere      [For elb]
                        Custom TCP - TCP - 8080 - Anywhere      [For Fargat/Container]
                Load balancer type: <x> Application load balancer
                    <x> Create a load balancer
                        Load balancer name: vpro-app-action-elb
                        Choose container to load balancer: vpro-app 8080:8080
                <x> Create new listener:
                    Port: 80
                    Protocol: HTTP
                <x> Create new target group
                    Name: vpro-app-action-tg
                    Health check: /login
        > Create
        - Verify the TG status
        - Update RDS security group
            EC2 > Security group > vpro-app-rds-actions-sg > Edit inbound rules >
                Add:
                    Custom TCP - TCP - 3306 - Custom - vpro-app-action-svc-sg
            > Save rules
        - Access vpro website using ELB DNS
            Login:
                user: admin_vp, pass: admin_vp
                    
## ECS deployment 
    - Add task definitation policy to source code
        ECS > Task definitions > vpro-app-tdf > Revision 1 > Containers > Json >
            - Copy the jeson text
            - Past to vpro_repo/aws-files/taskdeffile.json
                "<Json text>"
    - Update .github/workflow/main.yml
        - Update env section adding below variables
            ```
            env:
                ECR_REPOSITORY: action-app
                ECS_SERVICE: vpro-action-svc
                ECS_CLUSTER: vpro-app-action
                ECS_TASK_DEFINITION: aws-files/taskdeffile.json
                CONTAINER_NAME: vpro-app
            ```
        - Add 'Deploy' job
            ```Deploy:
                needs: BUILD_AND_PUBLISH
                runs-on: ubuntu-latest
                steps:
                - name: Code checkout
                    uses: actions/checkout@v4
                - name: Configure aws credentials
                uses: aws-actions/configure-aws-credentials@v4
                with:
                    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
                    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
                    aws-region: ${{ env.AWS_REGION }}

                - name: Fill in the new image ID in the Amazon ECS task definition
                id: task-def
                uses: aws-actions/amazon-ecs-render-task-definition@v1
                with:
                    task-definition: ${{env.ECS_TASK_DEFINITION}}
                    container-name: ${{env.CONTAINER_NAME}}
                    image: ${{ secrets.REGISTRY }}/${{ env.ECR_REGISTRY }}:${{github.run_number}}

                - name: Deploy Amazon ECS task definition
                uses: aws-actions/amazon-ecs-deploy-task-definition@v2
                with:
                    task-definition: ${{ steps.task-def.outputs.task-definition }}
                    service: ${{env.ECS_SERVICE}}
                    cluster: ${{env.ECS_CLUSTER}}
                    wait-for-service-stability: true
            ```
        - Commit and push
    - Run the workflow and verify the tasks executions
    - After verification success, make the workflow run on push as well
        on: [push, workflow_dispatch]
    - Commit and push

## Delete the resources
    - Delete RDS cluster
    - Delete ECS service cluster
    - Delete IAM user
    - and Security groups and other if any
