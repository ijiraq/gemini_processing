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

- Made a script to submit all my jobs to batch:

```txt
executable = run_nifty.bash

arguments = GN-2005B-SV-121
log = GN-2005B-SV-121.log
output = GN-2005B-SV-121.out
error = GN-2005B-SV-121.err
queue 1

arguments = GN-2006A-SV-122
log = GN-2006A-SV-122.log
output = GN-2006A-SV-122.out
error = GN-2006A-SV-122.err
queue 1

arguments = GN-2006B-Q-107
log = GN-2006B-Q-107.log
output = GN-2006B-Q-107.out
error = GN-2006B-Q-107.err
queue 1

arguments = GN-2006B-Q-26
log = GN-2006B-Q-26.log
output = GN-2006B-Q-26.out
error = GN-2006B-Q-26.err
queue 1

arguments = GN-2007A-Q-2
log = GN-2007A-Q-2.log
output = GN-2007A-Q-2.out
error = GN-2007A-Q-2.err
queue 1

arguments = GN-2007A-Q-3
log = GN-2007A-Q-3.log
output = GN-2007A-Q-3.out
error = GN-2007A-Q-3.err
queue 1

arguments = GN-2007A-Q-79
log = GN-2007A-Q-79.log
output = GN-2007A-Q-79.out
error = GN-2007A-Q-79.err
queue 1

arguments = GN-2009B-C-6
log = GN-2009B-C-6.log
output = GN-2009B-C-6.out
error = GN-2009B-C-6.err
queue 1

arguments = GN-2009B-Q-57
log = GN-2009B-Q-57.log
output = GN-2009B-Q-57.out
error = GN-2009B-Q-57.err
queue 1

arguments = GN-2010A-Q-67
log = GN-2010A-Q-67.log
output = GN-2010A-Q-67.out
error = GN-2010A-Q-67.err
queue 1

arguments = GN-2010B-Q-26
log = GN-2010B-Q-26.log
output = GN-2010B-Q-26.out
error = GN-2010B-Q-26.err
queue 1

arguments = GN-2010B-Q-61
log = GN-2010B-Q-61.log
output = GN-2010B-Q-61.out
error = GN-2010B-Q-61.err
queue 1

arguments = GN-2010B-Q-88
log = GN-2010B-Q-88.log
output = GN-2010B-Q-88.out
error = GN-2010B-Q-88.err
queue 1

arguments = GN-2011A-Q-43
log = GN-2011A-Q-43.log
output = GN-2011A-Q-43.out
error = GN-2011A-Q-43.err
queue 1

arguments = GN-2011A-Q-68
log = GN-2011A-Q-68.log
output = GN-2011A-Q-68.out
error = GN-2011A-Q-68.err
queue 1

arguments = GN-2011B-Q-39
log = GN-2011B-Q-39.log
output = GN-2011B-Q-39.out
error = GN-2011B-Q-39.err
queue 1

arguments = GN-2012A-Q-114
log = GN-2012A-Q-114.log
output = GN-2012A-Q-114.out
error = GN-2012A-Q-114.err
queue 1

arguments = GN-2012A-Q-13
log = GN-2012A-Q-13.log
output = GN-2012A-Q-13.out
error = GN-2012A-Q-13.err
queue 1

arguments = GN-2012A-Q-48
log = GN-2012A-Q-48.log
output = GN-2012A-Q-48.out
error = GN-2012A-Q-48.err
queue 1

arguments = GN-2012A-Q-92
log = GN-2012A-Q-92.log
output = GN-2012A-Q-92.out
error = GN-2012A-Q-92.err
queue 1

arguments = GN-2012B-Q-93
log = GN-2012B-Q-93.log
output = GN-2012B-Q-93.out
error = GN-2012B-Q-93.err
queue 1

arguments = GN-2013A-Q-62
log = GN-2013A-Q-62.log
output = GN-2013A-Q-62.out
error = GN-2013A-Q-62.err
queue 1

arguments = GN-2013A-Q-83
log = GN-2013A-Q-83.log
output = GN-2013A-Q-83.out
error = GN-2013A-Q-83.err
queue 1

arguments = GN-2014A-DD-4
log = GN-2014A-DD-4.log
output = GN-2014A-DD-4.out
error = GN-2014A-DD-4.err
queue 1

arguments = GN-2014A-Q-60
log = GN-2014A-Q-60.log
output = GN-2014A-Q-60.out
error = GN-2014A-Q-60.err
queue 1

arguments = GN-2014A-Q-85
log = GN-2014A-Q-85.log
output = GN-2014A-Q-85.out
error = GN-2014A-Q-85.err
queue 1

arguments = GN-2014B-Q-30
log = GN-2014B-Q-30.log
output = GN-2014B-Q-30.out
error = GN-2014B-Q-30.err
queue 1

arguments = GN-2014B-Q-46
log = GN-2014B-Q-46.log
output = GN-2014B-Q-46.out
error = GN-2014B-Q-46.err
queue 1

arguments = GN-2015A-Q-33
log = GN-2015A-Q-33.log
output = GN-2015A-Q-33.out
error = GN-2015A-Q-33.err
queue 

arguments = GN-2015A-Q-6
log = GN-2015A-Q-6.log
output = GN-2015A-Q-6.out
error = GN-2015A-Q-6.err
queue 1

arguments = GN-2015A-Q-66
log = GN-2015A-Q-66.log
output = GN-2015A-Q-66.out
error = GN-2015A-Q-66.err
queue 1

arguments = GN-2016A-FT-9
log = GN-2016A-FT-9.log
output = GN-2016A-FT-9.out
error = GN-2016A-FT-9.err
queue 1

arguments = GN-2016A-Q-12
log = GN-2016A-Q-12.log
output = GN-2016A-Q-12.out
error = GN-2016A-Q-12.err
queue 1

arguments = GN-2019A-FT-106
log = GN-2019A-FT-106.log
output = GN-2019A-FT-106.out
error = GN-2019A-FT-106.err
queue 1

arguments = GN-2019A-Q-208
log = GN-2019A-Q-208.log
output = GN-2019A-Q-208.out
error = GN-2019A-Q-208.err
queue 1

arguments = GN-2019B-FT-101
log = GN-2019B-FT-101.log
output = GN-2019B-FT-101.out
error = GN-2019B-FT-101.err
queue 1

```
























