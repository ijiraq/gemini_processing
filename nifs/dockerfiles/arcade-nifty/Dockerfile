# Dockerfile

FROM continuumio/miniconda

RUN dpkg --add-architecture i386
RUN apt-get update -y --fix-missing &&     apt-get upgrade -y &&     apt-get install -y xauth locales &&    /usr/sbin/update-locale LANG=C.UTF-8 &&     locale-gen C.UTF-8

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get install -y libc6:i386 libz1:i386 libncurses5:i386     libbz2-1.0:i386 libuuid1:i386 libxcb1:i386 libxmu6     libxss1 libxft2

RUN apt-get remove -y locales &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*

RUN conda config --add channels http://ssb.stsci.edu/astroconda

RUN conda create -y -n iraf27 python=2.7 iraf-all pyraf-all stsci

RUN conda clean -y -t

ENV PATH /opt/conda/envs/iraf27/bin:$PATH
RUN /bin/bash -c "source activate iraf27 && mkdir iraf && mkdir scratch"
RUN /bin/bash -c "apt-get update -y && apt-get install -y python-qt4"

WORKDIR /iraf

RUN /bin/bash -c "source activate iraf27 && mkiraf"

WORKDIR /scratch

# Create entrypoint script
COPY arcade_activate /usr/bin/
RUN ["chmod", "+x", "/usr/bin/arcade_activate"]

# Install development version of Nifty4Gemini
RUN pip install --upgrade pip && \
    pip install --no-cache-dir https://github.com/Nat1405/Nifty4Gemini/archive/dev.tar.gz && \
    pip install --no-cache-dir astroquery && \
    pip install --no-cache-dir pyvo

RUN pip install vos --upgrade --user

# Arcade container requirements
RUN apt update -y && apt install -y sssd libnss-sss libpam-sss xterm vim
ADD nsswitch.conf /etc

# Grant non-root users permissions
ENV HOME /scratch
RUN /bin/bash -c "chmod -R 777 /iraf && chmod -R 777 /scratch "

ENTRYPOINT [ "/usr/bin/arcade_activate" ]
CMD [ "/bin/bash" ]
