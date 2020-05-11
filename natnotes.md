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
		- Built with "docker build -t arcade-nifty:latest -f Dockerfile ."
		- Ran with a non-root user with "export UID=$(id -u) && export GID=$(id -g) && docker run -it --user $UID:$GID arcade-nifty"
		- Both seem to work

	- Arcade controls:

```bash
# List sessions
curl -E ~/.ssl/cadcproxy.pem https://proto.canfar.net/arcade/session

# Start a new session
curl -E ~/.ssl/cadcproxy.pem https://proto.canfar.net/arcade/session -d "name=Nat" -d "type=desktop"
# Delete a session, where <session id> is 8 character code from the list sessions command
curl -E ~/.ssl/cadcproxy.pem https://proto.canfar.net/arcade/session/<session id> -X DELETE
```

- After logging into Arcade:
	- Launch the terminal emulator
	- "cd /cavern/home/Nat/"
	- "./nifty.sh"
	- Woohoo!


### Updating Nifty to Support CADC Downloads

- Doing a test to just try and download a dataset from CADC
	- Queried for all cadc data from a particular program
		- "cadc-tap query -s argus "SELECT observationID FROM caom2.Observation WHERE instrument_name='NIFS' AND proposal_id='GN-2014A-Q-85'"
	- OKAY. Basically, we have a system for downloading data from CADC. Uses my standard "iraf27" environment, pyvo, and astroquery.

```python
from astroquery.cadc import Cadc
import urllib

cadc = Cadc()
job = cadc.create_async("SELECT observationID, publisherID, productID FROM caom2.Observation \
	                     AS o JOIN caom2.Plane AS p ON o.obsID=p.obsID \
	                     WHERE instrument_name='NIFS' AND proposal_id='GN-2014A-Q-85'")
job.run().wait()
job.raise_if_error()
result = job.fetch_result().to_table()
print(result)

# Store product id's for later
pids = list(result['productID'])

urls = cadc.get_data_urls(result)
for url, pid in zip(urls, pids):
	print(url)
	print(pid)
	urllib.urlretrieve(url, pid+".fits")
```

- Now let's try to add a new command line option to Nifty to download files from CADC.
	- Should work like "runNifty nifsPipeline -f --cadc GN-2014A-Q-85"


- Uploading changes to pypi
	- Just need to pick a good package name (not nifty4gemini), then in the Nifty4Gemini repo, run

```bash
rm -r dist/
python3 setup.py sdist bdist_wheel
twine upload dist/*
# Username: __token__
# Password: See real pypi api token.
```


### Creating a Representative NIFS dataset

- Get number of distinct NIFS programs: "cadc-tap query -s argus "SELECT COUNT (DISTINCT proposal_id) FROM caom2.Observation AS o JOIN caom2.Plane AS p ON o.obsID=p.obsID WHERE instrument_name='NIFS'" "

- Got all distinct proposal ids with representative.py

```python
from astroquery.cadc import Cadc
import urllib

cadc = Cadc()
job = cadc.create_async("SELECT DISTINCT proposal_id FROM caom2.Observation \
					AS o JOIN caom2.Plane AS p ON o.obsID=p.obsID \
					WHERE instrument_name='NIFS'")
job.run().wait()
job.raise_if_error()
result = job.fetch_result().to_table()
for item in result:
	print(item['proposal_id'])
```

- Get average exposure time associated with each proposal (keep in mind will be skewed by standard star exposure times, these are counted here)

```python
from astroquery.cadc import Cadc
import urllib

cadc = Cadc()
job = cadc.create_async("SELECT proposal_id, avg(time_exposure) AS val FROM caom2.Observation \
					AS o JOIN caom2.Plane AS p ON o.obsID=p.obsID \
					WHERE instrument_name='NIFS' AND type='OBJECT' AND proposal_id LIKE 'GN-2%' GROUP BY proposal_id ORDER BY proposal_id")
job.run().wait()
job.raise_if_error()
result = job.fetch_result().to_table()
print(result)
for item in result:
	print(str(item['proposal_id']) + ' ' + str(item['val']))
	#print(item['val'])
```

- Get number of targets associated with each proposal

```python
from astroquery.cadc import Cadc
import urllib

cadc = Cadc()
job = cadc.create_async("SELECT proposal_id, count( DISTINCT target_name ) AS val FROM caom2.Observation \
					AS o JOIN caom2.Plane AS p ON o.obsID=p.obsID \
					WHERE instrument_name='NIFS' AND type='OBJECT' AND proposal_id LIKE 'GN-2%' GROUP BY proposal_id ORDER BY proposal_id")
job.run().wait()
job.raise_if_error()
result = job.fetch_result().to_table()
print(result)
for item in result:
	#print(str(item['proposal_id']) + ' ' + str(item['val']))
	print(item['val'])
```





- Made a spreadsheet of all proposals with their abstract links
	- GN-2019A-Q-208
 	- GN-2012B-Q-74
 	- GN-2013A-Q-62

https://archive.gemini.edu/programinfo/GN-2019B-Q-228


















