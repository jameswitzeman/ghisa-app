#Get the base jupyter server image
FROM quay.io/jupyter/minimal-notebook

SHELL ["/bin/bash", "-c"]
USER root

#Get packages + pip stuff
RUN apt-get update && apt-get install -y python-pip && apt-get install -y git

COPY requirements.txt .
RUN apt-get --yes install libgeos-dev
RUN pip install install conda

#Download and setup LPDAAC (WIP)
RUN wget -O config.yml https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_python/raw/DDD_WindowsOS.yml?at=refs%2Fheads%2Fmain
RUN wget -O DAACDataDownload.py https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_python/raw/DAACDataDownload.py?at=refs%2Fheads%2Fmain
RUN sed -i '$d' config.yml

#GHISA pip dependencies
RUN pip install -r requirements.txt

RUN pip install --upgrade tornado
RUN pip install --upgrade holoviews
RUN pip install --upgrade hvplot

#Get the actual GHISA app, make it read/execute only for visitors
WORKDIR /
RUN git clone https://github.com/jameswitzeman/GHISA_Spectral_Visualization_App/

WORKDIR /work
RUN cp /GHISA_Spectral_Visualization_App/GHISA_Visualization.ipynb .

RUN chmod 555 GHISA_Visualization.ipynb

#WORKDIR /home/joyvan/
#COPY .netrc .
#RUN chmod 744 .netrc
