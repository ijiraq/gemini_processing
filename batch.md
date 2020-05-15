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

- Then I copied the github script https://raw.githubusercontent.com/canfar/canfarproc/master/worker/bin/canfar_batch_prepare to /usr/local/bin on the machine and added execute permissions, and ran it.
```bash
sudo canfar_batch_prepare
```
- And saved an image snapshot.

- Now onto the actual CANFAR batch server to see if we can get something going. FOllowing instructions from https://www.canfar.net/en/docs/quick_start/.
	- Login: nat@batch.canfar.net
	- Made a script to run nifty
	- needed to make a \~/.ssl directory on running the getCert command..
	- Submitted with canfar_submit quick_start.sub nifty-docker-0 c2-7.5gb-31
  - Monitored job status with `condor_status -submitter`
  - Jobs kept failing! Maybe it's because I'm using sudo in my script to launch the docker daemon?
    - Followed steps [here](https://docs.docker.com/engine/install/linux-postinstall/) to let docker run without sudo.
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```
- rebooted the vm
- Woohooo, `docker run hello-world` works now!
- Made a new snapshot
- Still doesn't work. Trying `canfar_submit --user=ubuntu myjob.jdl nat-nifty-0.1 c1-7.5gb-30`

- Trying to add a new "nat" user on the VM then rebuilding the image ( I found the canfar_create script from https://raw.githubusercontent.com/canfar/canfarproc/master/worker/bin/canfar_create_user)

```bash
sudo canfar_create_user nat
sudo  usermod -aG docker nat
```

- sshed into that container and `docker run hello-world` and `docker run nat1405/gemini:nifty runNifty nifsPipeline -f GN-2014A-Q-85'` both work!
- Re-snapshotted the image
- On batch, submitted with `canfar_submit myjob.jdl nat-nifty-0.2 c1-7.5gb-30`
- Used `cloud_status -m | grep nat` to get hostname (starts with cc-arbutus) of running VM
- Used `condor_q -better-analyze -reverse slot1@<hostname>` to see job info (didn't really help), maybe the IP of the running machine is in there...
- Added my public key (and made sure it had the right permissions) for the VM I built to my batch profile, then I could ssh into the running VM: `ssh -i ~/.ssh/<vm key> nat@<vm ip>`
- Could list the running containers with `docker ps` and attach with `docker attach <container id>` 

Awesome!



