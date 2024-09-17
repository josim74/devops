# CI Pipeline on AWS
## AWS Services
- Code Commit
- Code Artifact
- Code Build
- Code Deploy
- Sonar Cloud
- Check Style
- Code Pipeline

## Flow of execution
* Login to AWS account
* Code commit
    * Create codecommit repo
    * Create iam user with codecommit policy
    * Generate ssh keys with IAM user
    * Put source code from github repo to cc repository and push
* Code artifact
    * Create an IAM user with code artifact access
    * Install AWS CLI, configure
    * Export auth token
    * Update pom.xml file with repo details
* Sonar cloud
    * Create sonar cloud account
    * Generate token
    * Create SSM parameters with sonar details
    * Create build project
    * Update code build role to access SSMparameterstore
* Create notifications for sns or slack
    * Update pom.xml with artifact version with timestamp
    * Create variables in SSM => parameterstore
    * Create build project
    * Update codebuild role to access SSMparamterstore
* Create pipeline
    * Code commit
    * Test code
    * Buld
    * Deploy to s3 bucket

## Code commit setup in AWS
* Create code commit repository
    ```
    Developer Tools > CodeCommit > Repositories > Create repository
        name: vprofile-code-repo
    > Create
    ```
* Create IAM user with custom policies for CC
    ```
    IAM > Users > Create user >
        User name: vprofile-code-admin
        > Next >
        [*] Attach policies directly
        Create policy > 
            Policy editor: Visual
            Select a service: CodeCommit
            Manual actions: [*] All CodeCommit actions
            Resources: [*] Specific
            Repository: 
                Add ARNs > 
                    Resources: [*] This account
                    Resource region: us-east-1
                    Resource repository name: vprofile-code-repo [Same as CodeCommit repo name]
                > Add ARNS
            > Next >
                Name: vprofile-repo-full-access
        > Create policy
        Refresh policies
        [*] vprofile-repo-full-access
        > Next >
    Create user
    > Security credentials > Create access key >
        Use case: [*] Command line interface
        [*] I understand the...
        > Next > Create access key
        ** Download the CSV file
    Finally configure AWS CLI with this IAM user but remember for region.
    ```
* SSH auth to CodeCommit repo
    ```
    - Generate ssh key in local machine of not generated
    - Upload to IAM user and take the ID
    - Configure SSH config file with IAM user and SSH private key as below [Ref aws-ci branch ssh config file]
        Host git-codecommit.*.amazonaws.com
        User APKAXIXFJTQEW2ZCTWED
        IdentityFile ~/.ssh/vpro-codecommit_rsa
    - Authenticate AWS CodeCommit from CLI with below command
        ssh git-codecommit.us-east.amazonaws.com
        [** in case of any issue 'ssh -v git-codecommit.us-east.amazonaws.com']
    ```
* Migrate vprofile project repo from Github to CodeCommit
    ```
    - Clone git github repo in local machine
    - Check out all the branches to push to CodeCommit
        [* bash loop can be use to do it]
    - Remove remote url
        git remote rm origin
    - Add AWS CodeCommit with SSH url
        git remote add origin <CodeCommit URL>
    - Push all branches to AWS CodeCommit
        git push origin --all   [** Verify in AWS CodeCommit]
    ```
* Sonar cloud
    ```
        - Go to sonarcloud.io and login with github account
        - My account > Security > generate token >
            title: vpro-sonar-cloud
        > Generate token
        - Copy token and save
        - Click on '+' symbol > Create organization >
            name: hkhinfo tech
            Chose plan: Free
        > Create organization
        - Analyze new project > Create a project mannually > 
            Organization: <Select> hkhinfo tech
            Display name: hkhvprofile-repo
            Project key: hkhvprofile-repo
            Visibility: public
            [*] Previous version
        > Create project > information > Copy project key and save
        - Copy organization name and save
        - Also save sonar url [Url: https://sonarcloud.io]
    ```
* Aws system manager parameter store for sonar details
    ```
        - System manager > Parameter store >
            Name: Organization
            Tier: Standared
            Type: String
            Data type: Text
            Value: hkhinfo tech
        > Create parameter
        - System manager > Parameter store >
            Name: HOST
            Tire: Standared
            Type String
            Data type: Text
            Value: https://sonarcloud.io
        - Similarly
            Prjoect: hkhprofile-repo    [* Project key]
            LOGIN: <Token>  [* Type: Secure string]

## AWS CodeArtifact setup and systems manager parameter store
* Create code artifact for maven dependencies
    ```
    AWS > Developer tools > CodeArtifact > Create repository >
        Repository name: vprofile-maven-repo
        Public upstream repositories: <Select> maven-central-store
    > Next >
        AWS account: [*] This account
        Domain name: hkhinfo tech
    > Next > Create repository
    
    - Verify connections
    maven-center > View connection instructions >
        operating system: mac & linux
        Choose package manager client: mvn
        Select a configuration method: Pull from your repository
        Update settings.xml and pom.mxl files accordingly
        [** Learn more about aws build spec; branch: aws-ci; source: aws-files/build-spec.yml, sonar-spec.yml]
    
## AWS code build for sonarqube code analysis 
    ```
    - File name must be buildspec.yml
    - Modify buldspec.yml file according to maven-central-store corde artifact
        CodeArtifact > maven-central-store > View connectinos instructions >
        Operation System: [*] Mac * Linux
        Step1: Choose package manager
        Client: <Select> mvn
        [* Update pom.xml by adding the sonar URL and update settings.xml file according to the connections instructions]
    - Commit the codes to the aws code commit repo [* Bitbucket]
    - Create code build job in aws
        Developer tools > Code build > Build projects > Create build project >
            Project name: vpro-code-analysis
            Source provider: Bitbucket
            Repository: [*] Connect using OAuth
            Click on 'Connect to buildbucket'   [* Login bitbucket from same browser]
            Repository: [*] Repository in my Bitbucket account
            <Select> <Bit bucket repo> url>
            Source version: ci-aws [Branch]
            Environment: [*] ondemand image
            Environment image: [*] managed image
            Compute: EC2
            Operating system: Ubuntu
            Runtime: Standared
            Image: aws/codebuild/standared7.0
            Image version: always use the latest image for this runtime
            Service role: [*] New service role
                name: codebuild51-vpro-coe-analysis-service-role
                Buildspec: [*] User a buildspec file
            [*] Cloud watch log:
                Group name: vprofile-nvir-codebuild
                Stream name: SonarcodeAnalysis
        > Create build project
        - Create iam policy according to the service role is being used
            IAM > roles > codebuild51-vpro-code-analysis-service-role > Permissions > 
                [* There should be two policies 1. CodeBuildBasedPolicy-vpro..., 2. CodeBuildCloudWatchPolicy-vpro...]
            - Create new policy
                IAM > Policies > Create policy >
                    <Select> Systems manager
                    List: [*] DescribeParameters
                    Read:
                        [*] Describe document parameter
                        [*] Get parameter
                        [*] Get parameters
                        [*] Get parameter history
                        [*] Get parameter by path
                    > Next >
                        Policy name: vprofile-parametersReadPermission
                    > Create policy
            - Add teh policy to 'codebuild51-...' role
            - Also add 'AWSCodeArtifactReadOnlyAccess' to 'codebuild51...' role
    - Try the build and check the log for details info
    - Check the sonarcloud project once the build is success

## AWS code build for artifact (buildspec.yml)
    - Source ref:
        Branch: ci-aws
        path: aws-files/build-builspec.yml
    - Update code artifact token
        Developer tools > Codeartifact > Repositories > maven-central-store > View connections instructions >
            OS: mac & linux
            copy and update the token in buildspec.yml file
    - Commit and push to the update
    - Create code build job
        Developer tools > Codebuild > Build project > Create build project > 
            Project name: vprofile-build-artifact
            Source provider: bitbucket
            Repository: [*] Repository in my account
                <Select> <Repo url>
            Source version: ci-aws
            Operating system: Ubuntu
            Image: aws/codebuld/standared7.0
            Service role: [*] New service role
                Role name: codebuild51-vprofile-build-artifact-service-rol
            Buildspec creations: [*] Use a buildspec file
            Buildspec name: aws/files/build-buildspec.yml
            [*] Cloud watch logs
            Group name: vprofile-nvir-codebuild     [* Same as previous]
            Stream name: Build artifact
        > Create build project
    - Update the code build service role
        IAM > Roles > codebuild51-vprofile-build-articat-service-role > Add permission > Attach policies >
            [*] AWS codeArtifactReadOnlyAccess
        > Add policies
    - Test the build job. If issue raises show the details log
## AWS code pipeline and notifications with SNS
    - Configure notification before creating pipeline
        - Create s3 bucket
            Amazon s3 > Buckets > Create bucket
                Bucket name: vprofile-build-artifact
                Region: us-east-1
            > Create bucket > Create folder in bucket >
                Folder name: pipeline-artifact
            > Create folder
        - Create SNS (Simple notification service)
            SNS > Topics > Create topic >
                [*] Standared
                Name: vprofile-pipeline-notification
            > Create topic > Create subscriptions >
                Protocol: <Select> Email
                endpoint: uddinj519@gmail.com
            > Create subscription
            - Confirm subscriptions from email inbox
        - Create pipeline
            Pipeline name: vprofile-ci-pipeline
            Service role: [*] New service role
                Role name: AWSCodePipelineServiceRole-us-east-1-vprofile-ci-pipeline51
            > Next >
                Source provider: <Select> AWSCodeCommit
                Repository name: vprofile-code-repo
                Branch name: ci-aws
                [*] Amazoncloud watch event
            > Next >
                Build provider: AWS Codebuild
                Region: US East (N.verginia)
                Project name: <Select> vprofile-build-artifact
            > Skip (For now, will update later)> Create pipeline > Stop execution > 
                <Select> <The id which is created>
            > Stop and wait > Stop
        - Edit vprofile-ci-pipeline >
            Add stage > 
                Stage name: CodeAnalysis
            > Add
            > Add action >
                Action name: Sonarcode analysiss
                Action provider: AWScodebuildjob
                Input artifact: Sourceartifact
                Project name: Code analysis
            > Done > Done (again)
            Deploy > Add stage > Add action >
                Action name: Deploy to s3
                Action provider: Amazon s3
                Input artifact: Buildartifact
                Bucket: vprofile51-build-artifact
                S3 object key: Pipeline artifacts   [Folder name]
                [*] Extract before deploy
            > Done > Done (Again)
            > Save (Must) > Save (again)
        - Vprofile-ci-pipeline > Settings > Notifications > Create notification role >
            Notification name: vprofile-ci-notifications
                [*]
                Events: <Select> All
                SNS topic: <Select> vprofile-pipeline-notification
            > Submit >
            > vprofile-ci-pipeline > Release change> Release
        - Validate the pipeline
            - Push a test commit
            - It should trigger the pipeline
            - If build got failed the mail will be sent
            




