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
CMD [ "/bin/bash" ]
