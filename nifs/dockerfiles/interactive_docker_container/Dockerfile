FROM michaelcs/astrocondairaf

ENV PATH /opt/conda/envs/iraf27/bin:$PATH
RUN /bin/bash -c "source activate iraf27 && mkdir iraf && mkdir scratch && conda install pyqt=4"

RUN pip install --upgrade pip && \
    pip install --no-cache-dir nifty4gemini

WORKDIR /iraf

RUN /bin/bash -c "source activate iraf27 && mkiraf"

RUN /bin/bash -c "echo 'source activate iraf27' > /root/.bashrc && echo 'if [ ! -f "/scratch/login.cl" ]; then ln -s /iraf/login.cl /scratch/login.cl; fi' >> /root/.bashrc"

WORKDIR /scratch