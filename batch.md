# Notes on getting batch mode running

- Got an Ubuntu VM running with some instructions:
	- https://www.canfar.net/en/docs/quick_start/
	- https://docs.computecanada.ca/wiki/Creating_a_Linux_VM

- ssh'd into the VM and installed software for docker:
	- https://docs.docker.com/engine/install/ubuntu/

```bash
sudo apt-get update -y
# Remove old docker software
sudo apt-get remove docker docker-engine docker.io containerd runc
# Start Docker installation
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Check fingerprint is correct, perhaps we should do this differently with grep or something...
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Download test image to check it's working; could be done better with grep or something...
sudo docker run hello-world

# Now my testing
sudo docker pull nat1405/gemini:nifty
```