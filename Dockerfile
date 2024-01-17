FROM quay.io/jupyter/minimal-notebook

SHELL ["/bin/bash", "-c"]
USER root

RUN apt-get update && apt-get install -y python-pip && apt-get install -y git

COPY requirements.txt .
RUN apt-get --yes install libgeos-dev
RUN pip install install conda
RUN wget -O config.yml https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_python/raw/DDD_WindowsOS.yml?at=refs%2Fheads%2Fmain
RUN wget -O DAACDataDownload.py https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_python/raw/DAACDataDownload.py?at=refs%2Fheads%2Fmain
RUN sed -i '$d' config.yml

RUN pip install -r requirements.txt

RUN pip install --upgrade tornado
RUN pip install --upgrade holoviews
RUN pip install --upgrade hvplot

WORKDIR /work
RUN git clone https://github.com/jameswitzeman/GHISA_Spectral_Visualization_App/

RUN chmod 555 GHISA_Spectral_Visualization_App

WORKDIR /home/joyvan/
COPY .netrc .
RUN chmod 744 .netrc
