    # Update repositories
    sudo apt update -y

    # Upgrade installed packages
    sudo apt upgrade -y

    #Enable universe repository
    sudo add-apt-repository universe -y
    sudo apt update -y

    # Add desktop environment
    sudo apt install -y --no-install-recommends ubuntu-desktop
    sudo apt install -y --no-install-recommends virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
    # Add `vagrant` to Administrator
    sudo usermod -a -G sudo vagrant

    # Install docker
    ## Add docker's official GPG key
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    ## Install docker latest version
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ## Verify docker installation
    sudo docker run hello-world

    # Install nodeJS
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    node -v
    npm -v

    # Install MongoDB
    ## Import public key then install
    sudo apt-get install gnupg -y

    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
    
    sudo apt-get update -y
    sudo apt-get install -y mongodb-org

    # Check Mongo DB service
    sudo systemctl start mongod

