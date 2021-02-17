# Dockerfile

FROM continuumio/miniconda3

RUN conda config --add channels http://astroconda.gemini.edu/public && \
	conda config --add channels http://ssb.stsci.edu/astroconda && \
	conda create -n dragons python=3.6 dragons stsci && \
    conda clean --all -f -y

# Create entrypoint script
COPY arcade_activate /usr/bin/
RUN ["chmod", "+x", "/usr/bin/arcade_activate"]

# Arcade container requirements
ADD nsswitch.conf /etc

RUN pip install --upgrade pip && \
    pip install --no-cache-dir 'astroquery==0.4' && \
    pip install --no-cache-dir pyvo && \
    pip install vos --upgrade --user

# echo $TIMESTAMP to force re-install of latest version from GitHub
ARG TIMESTAMP
RUN echo $TIMESTAMP && \
	pip install --no-cache-dir https://github.com/Nat1405/niriPipe/archive/pip_package.tar.gz

ENTRYPOINT [ "/usr/bin/arcade_activate" ]
CMD [ "/bin/bash" ]
