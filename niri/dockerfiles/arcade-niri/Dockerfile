# Dockerfile

FROM continuumio/miniconda

RUN dpkg --add-architecture i386
RUN apt-get update -y --fix-missing &&     apt-get upgrade -y &&     apt-get install -y xauth locales &&    /usr/sbin/update-locale LANG=C.UTF-8 &&     locale-gen C.UTF-8

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get install -y libc6:i386 libz1:i386 libncurses5:i386     libbz2-1.0:i386 libuuid1:i386 libxcb1:i386 libxmu6     libxss1 libxft2

RUN apt-get remove -y locales &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*

RUN conda config --set auto_activate_base false && conda config --add channels http://ssb.stsci.edu/astroconda && conda config --add channels http://astroconda.gemini.edu/public

RUN conda create -n geminiconda2 python=2.7 gemini stsci iraf-all pyraf-all

RUN conda create -n dragons python=3.6 dragons stsci

RUN conda clean -y -t

ENV PATH /opt/conda/envs/iraf27/bin:$PATH
RUN /bin/bash -c "source activate geminiconda2 && mkdir iraf && mkdir scratch"
RUN /bin/bash -c "apt-get update -y && apt-get install -y python-qt4"

WORKDIR /iraf

RUN /bin/bash -c "source activate geminiconda2 && mkiraf"

WORKDIR /scratch

# Create entrypoint script
COPY arcade_activate /usr/bin/
RUN ["chmod", "+x", "/usr/bin/arcade_activate"]

# Install development version of Nifty4Gemini
RUN pip install --upgrade pip && \
    pip install --no-cache-dir 'astroquery==0.4' && \
    pip install --no-cache-dir pyvo

RUN pip install vos --upgrade --user

# Arcade container requirements
RUN apt update -y && apt install -y sssd libnss-sss libpam-sss xterm vim nano emacs
ADD nsswitch.conf /etc

# Grant non-root users permissions
ENV HOME /scratch
RUN /bin/bash -c "chmod -R 777 /iraf && chmod -R 777 /scratch "

ENTRYPOINT [ "/usr/bin/arcade_activate" ]
CMD [ "/bin/bash" ]
