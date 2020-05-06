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
COPY arcade_activate /usr/bin/
RUN ["chmod", "+x", "/usr/bin/arcade_activate"]

# Arcade container requirements
RUN apt update -y && apt install -y sssd libnss-sss libpam-sss
ADD nsswitch.conf /etc

# Grant non-root users permissions
ENV HOME /scratch
RUN /bin/bash -c "chmod -R 777 /iraf && chmod -R 777 /scratch "

ENTRYPOINT [ "/usr/bin/arcade_activate" ]
CMD [ "/bin/bash" ]
