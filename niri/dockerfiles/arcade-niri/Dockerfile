# Dockerfile

FROM continuumio/miniconda3

# Install text editors
RUN apt-get update && \
	apt-get install -y vim nano xterm curl

RUN conda config --add channels http://astroconda.gemini.edu/public && \
	conda config --add channels http://ssb.stsci.edu/astroconda && \
	conda create -n dragons python=3.6 dragons stsci && \
	# Make sure to use latest version of DRAGONS
	conda update -n dragons dragons && \
    conda clean --all -f -y

# Create entrypoint script
COPY arcade_activate /usr/bin/
RUN ["chmod", "+x", "/usr/bin/arcade_activate"]

# Arcade container requirements
ADD nsswitch.conf /etc

RUN conda run -n dragons pip install --upgrade pip && \
    conda run -n dragons pip install --no-cache-dir 'astroquery==0.4' && \
    conda run -n dragons pip install --no-cache-dir pyvo && \
    conda run -n dragons pip install vos --upgrade --user

# NOTE: need to have a clone of niriPipe repo in this working directory
# for this build to work.
COPY niriPipe /niriPipe
RUN conda run -n dragons pip install /niriPipe

ENTRYPOINT [ "/usr/bin/arcade_activate" ]
CMD [ "/bin/bash" ]
