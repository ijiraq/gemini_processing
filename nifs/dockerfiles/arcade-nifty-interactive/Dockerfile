FROM michaelcs/astrocondairaf


# Additions to work with arcade
RUN apt update -y && apt install -y sssd libnss-sss libpam-sss

# To get iraf/pyraf working
ENV PATH /opt/conda/envs/iraf27/bin:$PATH
RUN /bin/bash -c "source activate iraf27 && mkdir iraf && mkdir scratch && conda install pyqt=4"

# Install Nifty4Gemini
RUN pip install --upgrade pip && \
    pip install --no-cache-dir nifty4gemini

# Set up iraf
WORKDIR /iraf
RUN /bin/bash -c "source activate iraf27 && mkiraf"

WORKDIR /scratch

# Adds iraf's login.cl to nifty's working directory.
RUN /bin/bash -c "echo 'source activate iraf27' > /root/.bashrc && echo 'if [ ! -f "/scratch/login.cl" ]; then ln -s /iraf/login.cl /scratch/login.cl; fi' >> /root/.bashrc"

WORKDIR /scratch

# By default launch an interactive shell.
CMD ["/bin/bash"]
