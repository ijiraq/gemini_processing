# Nat's Logbook

Just a space for me to keep notes on what I'm up to, how progress is happening, and so others can follow in my footsteps. Not well maintained or polished yet; use at your own risk!

## Questions

- What are some attributes that your truly exceptional Co-op students have shown? Ie, what do you really like to see in students?

## The Notes

### Dockerizing Nifty

In relation to #2. Goal is to get Nifty running in a Docker container.

- Created an Ubuntu 20.04 VM, tried to get Nifty4Gemini 1.0.1 installed.
	- Too slow?

- Installed docker 19.03.8 on a mac
	- Got the base anaconda image up and running. https://hub.docker.com/r/continuumio/anaconda/ . Ran ipython and conda.
	- Got Nifty running in a docker image 
		- https://hub.docker.com/r/michaelcs/astrocondairaf
		- Built with "docker pull michaelcs/astrocondairaf"
		- Launched (while mirroring a local directory so I could edit my login.cl): "docker run -i -t -v /Users/nat/new_iraf:/iraf michaelcs/astrocondairaf /bin/bash"
		- Activated relevant conda environment with "source activate iraf27"
		- Made a new "/iraf" directory and ran "mkiraf" within it
		- Got nifty4gemini installed by downloading source and running "pip install -e ."
		- Launched nifty with "runNifty nifsPipeline config.cfg" with the Titan config file, it started!!!
	- Now working on getting the docker image automatically created
		- This one creates a working interactive nifty4gemini container:
			- Built it with "docker build --tag nifty:1.0 ."
			- Launched it with "docker run -i -t -v /Volumes/NATGEMINI/docker/GN-2014A-Q-85:/scratch nifty:1.0 /bin/bash"
			- Run a full reduction in it with "runNifty nifsPipeline -f GN-2014A-Q-85"

		```text
		FROM michaelcs/astrocondairaf

		ENV PATH /opt/conda/envs/iraf27/bin:$PATH
		RUN /bin/bash -c "source activate iraf27 && mkdir iraf && mkdir scratch && conda install pyqt=4"

		RUN pip install --upgrade pip && \
		    pip install --no-cache-dir nifty4gemini

		WORKDIR /iraf

		RUN /bin/bash -c "source activate iraf27 && mkiraf"

		RUN /bin/bash -c "echo 'source activate iraf27' > /root/.bashrc && echo 'if [ ! -f "/scratch/login.cl" ]; then ln -s /iraf/login.cl /scratch/login.cl; fi' >> /root/.bashrc"

		WORKDIR /scratch
		```

	- Now working on getting on to be able to launch a reduction with "docker run -t nifty program_id" as per JJ's request
		- Built with "docker build --tag auto_nifty:1.0 ."
		- Ran with "docker run -t auto_nifty:1.0 <PROGRAM ID>"
		- See the Dockerfile and "entrypoint.sh" script

		```text
		# Dockerfile

		FROM michaelcs/astrocondairaf

		ENV PATH /opt/conda/envs/iraf27/bin:$PATH
		RUN /bin/bash -c "source activate iraf27 && mkdir iraf && mkdir scratch && conda install pyqt=4"

		RUN pip install --upgrade pip && \
		    pip install --no-cache-dir nifty4gemini

		WORKDIR /iraf

		RUN /bin/bash -c "source activate iraf27 && mkiraf"

		WORKDIR /scratch

		# Create entrypoint script
		COPY entrypoint.sh /scratch
		RUN ["chmod", "+x", "/scratch/entrypoint.sh"]

		ENTRYPOINT [ "/scratch/entrypoint.sh" ]
		CMD [ "GN-2014A-Q-85" ]
		```

		```text
		#!/bin/bash

		ln -s /iraf/login.cl /scratch/login.cl

		source activate iraf27

		runNifty nifsPipeline -f $1
		```

	- Creating arcade versions of both of these things
		- Used https://github.com/opencadc/arcade/tree/master/software-containers as inspiration to create docker containers
		- Built with commands in Makefiles
		- Both seem to work
	
























