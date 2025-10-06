FROM nvidia/cuda:12.3.2-runtime-ubuntu22.04

LABEL app="BepiPred"
LABEL version="3.0"
LABEL description="Prediction of potential B-cell epitopes from protein sequence"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        python3 python3-pip python3-venv libgomp1 unzip curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python3 /usr/bin/python

COPY bepipred3.zip /tmp/bepipred3.zip
RUN unzip /tmp/bepipred3.zip -d / && rm -f /tmp/bepipred3.zip

RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

ENV PATH=/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

RUN mkdir -p /models && \
    curl -o /models/esm2_t33_650M_UR50D-contact-regression.pt https://dl.fbaipublicfiles.com/fair-esm/regression/esm2_t33_650M_UR50D-contact-regression.pt && \
    curl -o /models/esm2_t33_650M_UR50D.pt https://dl.fbaipublicfiles.com/fair-esm/models/esm2_t33_650M_UR50D.pt

WORKDIR /

RUN apt-get remove --purge -y unzip curl && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
ENTRYPOINT ["python", "bepipred3_CLI.py"]
