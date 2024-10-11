# Continuous deployment with Jenkins

## Branches and web hook
- Update the security group rules if instance are created previously
- Add jenkins ip to Github we hook
- IP: http://<ip>:8080/github-webhook
- Verify the delivery
- Go to project reop (github)
    - Branch: docker
    - Download zip file
    - Copy tDocker-files
    - Go to the ci repo (local)
        branch: ci-jenkins
    - Checkout to a new branch
    - git checkout -b cicd-jenkins
        paste the Docker-files dir here
    - Create two direcotries in root
        mkdir Stagepipeline Prodpipeline
    - Copy the Jeninsfile to Stagepipeline and Prodpipeline direcotry and remove form root
    - Validate the git config
        cat .git/config
        - make sure for 'ci-jenkins' merge=refs/heads/ci-jenkins
    - Commit and push the code to cicd-jenkins branch

## AWS ECR and ECS
    - Create iam
        IAM > Users > Add user > 
            User name: cicd-jenkins
            <x> Access key-programming access
        > Next > Attach existing policies directly
            <x> AmazonECRContainerRegistryFullAccess
            <x> AmazonECSFullAccess
        > Next > Next > Create user
        - Download CSV file
    - Create ECR
        Amazon ECR > Repositories > Create repository >
            <x> Private
            Repository name: vprofile-app-img
        > Create repository
## Jenkins config
    - Install plugins
        1. Docker pipeline
        2. Cloudbees Docker build and publish
        3. Amazon ECR
        4. AWS pipeline steps
    - Save aws credentials
        Manage jenkins > Manage credentials > Store scoped to jenkins > Jenkins > Global credentials > Add credentials >
            Kind: AWS credentials
            Scope: Global (Jenkins)
            ID: awscreds
            Descriptions: awdcreds
            Access key: <IAM access key ID>
            Secret access key: <IAM secret key>
## Install docker ending to jenkins servicer and AWS cli
    - apt update && install awscli - y
    - Follow the docker installation steps form official site
    - Add jenkins user in the docker group
        usermod -aG docker jenkins
        id jenkins  [Verify the jenkins user]
    - Restart jenkins service
        systemctl restart jenkins
## Docker build in pipeline
    - Check previous ci pipeline, may need to change the build command in ci-jenkins branch
    - Open cicd-jenkins branch in VSCode
        app image(tomcat): Dockerfile/app/multistage
    - Stagepipeline/Jenkinsfile
        - Add 3 props in environment variable
            environment{
                registryCredentials = ecr.us-east-1:awscreds
                appRegistry = "<Amazon ECR URL>"
                vprofileRegistry = "https://<URI till amazonaws.com>"
            }
        - Fix build command
            maven1 => mvn
        - Add new stage
            Stage('Build app image'){
                steps{
                    script{
                        dockerimage = docker.build(appRegistry + "$BUILD_NUMBER", ".Dockerfiles/app/multistage")
                    }
                }
            }
        - Add stage('Upload app image'){
            steps{
                script{
                    docker:withRegistry(vprofileRegistry, registryCredentials){
                        dockerImage:push("$BUILD_NUMBER")
                        dockerImage:push('latest')
                    }
                }
            }
        }
        - Commit and push to cicd-jenkins branch
## Create a new pipeline in jenkins
    Jenkins > New item
        Name: vprofile-cicd-pipline-docker
        <Select> pipeline
    > Ok >
        Build triggers:
            <x> Github hook trigger from Git SCM polling
            Pipeline: Pipeline script from SCM
            SCM: Git
            Repo URL: <SSH URL>
            Credentials: git(github login)
            branch: */cicd-jenkins
            Script path: Stagepipeline/Jenkinsfile
        >Save > Build now
## AWS ECS
    - ECS cluster for staging
        ECS > Create cluster >
            Cluster name: vprofile-staging
            VPC: default
            subnets: All
            <x> AWS Fargate (server less)
            Monitoring: <on> Use container insights
                log: Name: vprofile-staging
        > Create
    - Create task define actions
        ECS > Create new task defination
        Task defination family: vprofile-app-stage-task
        Container name:
            Name: vpro-app
            URL: <Docker Registry URI>
            Container prot: 8080
        > Next >
            App environment: AWS Fargate (server less)
            Operating system: Linux/x86-64
            CPU: 1vcup
            Memory: 2GB
        > Next > Create
    - Create service
        ECS > Cluster > vprofile-staging > Service > Deploy
        Compute option: <x> Launch type
        Application type: <x> Service
        Family: vprofile-app-stage-svc
        Desire task: 1
        Security group: <x> Create new security group
        Service group name: vprofile-stage-sg
        Descriptions: vprofile-stage-sg
        Inbound rulest:
            HTTP - TCP - 80 - Anywhere
        Load balancer type: Application load balancer
        <x> Create new load balancer
            Load balancer name: vprofile-app-stage-elb
            Choose container to load balacer: vpro-app 8080:8080
        <x> Create target goup
            Target group name: vpro-app-stage-tg
            Protocol: HTTP
            Health check: /login
            Health check grace period: 30
        > Deploy
    - Update the target group
        EC2 > Target group > vpro-app-stage > Edit health check settings > Advanced health check settings >
            <x> Override 8080
        > Save change
    - Update security group
        EC2 > Security groups > vpro-app-stage-sg > Edit inbound rules > Add rule > 
            Custom TCP - TCP - 8080 - anewhere ipv4
            Custom TCP - TCP - 8080 - anewhere ipv6
        > Save rules
    - Check the deployment from ECS
        - ECS > Cluster vpro-staging > Service > vpro-app-prod-svc > Networking > Load balancer DNS
        - Also check tasks and task logs
## Pipeline for ECS deployment
    - Update IP in Github we hook in case of jenkins IP change
    - Update jenkins file
        environment{
            cluster = "vpro-staging"
            service = "vpro-app-prod-svc"
        }
        stage{
            steps{
                withAWS(credentials:'awscreds', region:'us-east-1'){
                    sh 'aws ecs update-service -cluster ${cluster} -service $(service) -force-new-deployment'
                }
            }
        }
    - Commit and push
    - Verify the build trigger and staging deployment
## Production pipeling setup
    - Create ECS cluster for production
        ECS > Cluster > Create cluster
            Cluster name: vpro-prod
            VPC: Default
            Subnets: All
        > Create
    - Create new task defination
        ECS > Create new tasks defination
            Task defination family: vpro-prod-task
            Container name: vpro-app
            Image URI: <Same Image URL as Stage>
            Container port: 8080
            Protocol: TCP
        > Next >
            App environment: AWS Farget (Server less)
            OS/Arc: Linux/x86-64
            CPU: 1vcpu
            Memory: 2GB
        > Next > Create
    - Deploy cluster
        ECS > Cluster > vpro-prod > Service > Deploy >
            Compute option: <x> Launch type
            Family: <Select> vpro-prod-task
            Service name: vpro-app-prod-svc
            Desire tasks: 1
            Vpc: Default
            Subnets: All
            Security group: <x> Create  security group
                Security group name: vpro-app-prod-svc-sg
                Descriptions: vpro-app-prod-svc-sg
                Inbound rule:
                    HTTP - TCP - 80 - Anywhere
            Load balancher type: Application loadbalancer
                Loadbalancer name: vpro-app-prod-svc-elb
                Choose container to load balancer: vpro-app 8080:8080
            Target group: <x> Create new target group
                Target group name: vpro-app-prod-svc-tg
                Protocol: HTTP
                Health check path: /login
                Health check grace period: 30
        > Deploy
    - Update target group
        ECS > Target groups > vpro-app-prod-svc-tg > Edit health check > Advanced health check settings >
            Port: <x> Override 8080
        > Save change
    - Update security group
        ECS > Security groups > vpro-app-prod-svc-sg > Edit inbound rules >
            Custom TCP - TCP - 8080 - Anywhere ip v4
            Custom TCP - TCP - 8080 - Anywhere ip v6
        > Save rules
    - Check the tasks health status
    - Production pipeline for jenkins
        - Go to local source code and create new branch from cicd-jenkins
            git checkout -b prod
        - Open Pipeline/Jenkinsfile in VSCode
            environment{
                cluster = "vpro-app"
                service = "vpro-app-prod-svc"
            }
            stage('Deploy to prod ECS'){
                steps{
                    withAWS(credentials:awscreds...Same as staging part)
                }
            }
        - Commit and push
    - Create new pipeline for production in jenkins
        Jenins > New item>
            Name: vprofile-cicd-prod-pipeline
            copy from: vprofile-cicd-pipeline-docker
        > Ok >
            Branch: */prod
            Script path: Prodpipeline/Jenkins
        > Save
    - Each commit should trigger the pipeline
## Full workflow from CI to CD
    - Commit any change to the cicd-jenkins branch
    - Check the cicd-pipeline-docker build in jenkins
    - Once the pipline build success
    - Create pull request to prod branch
    - Onnce pullrequest approved and merge to prod
    - The cicd-prod-pipeline should be trigger
    - Check the pipeline build status and load balancer DNS to verify

## Delete aws resources step by step
    - Delete service
    - Delete task
    - Delete cluster