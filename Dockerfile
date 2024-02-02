#Get the base jupyter server image
FROM quay.io/jupyter/minimal-notebook

SHELL ["/bin/bash", "-c"]
USER root
ENV DOCKER_STACKS_JUPYTER_CMD=notebook

#Get packages + pip stuff
RUN apt-get update && apt-get install -y python-pip && apt-get install -y git

RUN apt-get --yes install libgeos-dev
RUN pip install install conda

#Download and setup LPDAAC (WIP)
WORKDIR /LPDAAC
COPY ./format.py .

  #Get the download script from NASA
RUN wget -O DAACDataDownload.py https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_python/raw/DAACDataDownload.py?at=refs%2Fheads%2Fmain
  #Make sure the script is executable
RUN chmod 555 DAACDataDownload.py


  #Get the list of data we need to download
COPY downloads.txt .
COPY netrc /home/jovyan/.netrc
RUN python DAACDataDownload.py -dir . -f downloads.txt
RUN rm .netrc

#Format the data docs
RUN python format.py

#GHISA pip dependencies
WORKDIR /home/jovyan
COPY requirements.txt .
RUN pip install -r requirements.txt

RUN pip install --upgrade tornado
RUN pip install --upgrade holoviews
RUN pip install --upgrade hvplot

#Get the actual GHISA app, make it read/execute only for visitors
WORKDIR /
RUN git clone https://github.com/jameswitzeman/GHISA_Spectral_Visualization_App/
RUN mv desis_spectral_library_data_release.csv /LPDAAC
RUN mv prisma_spectral_library_data_release.csv /LPDAAC

WORKDIR /work
RUN mv /GHISA_Spectral_Visualization_App/GHISA_Visualization.ipynb .

#MAKE SURE THIS IS 555 IN PROD
RUN chmod 777 GHISA_Visualization.ipynb
RUN chmod 777 /home/joyvan/work/GHISA_Visualization.ipynb

