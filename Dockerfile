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
COPY ./tag-delete.py .

  #Get the download script from NASA
RUN wget -O DAACDataDownload.py https://git.earthdata.nasa.gov/projects/LPDUR/repos/daac_data_download_python/raw/DAACDataDownload.py?at=refs%2Fheads%2Fmain
  #Make sure the script is executable
RUN chmod 555 DAACDataDownload.py


  #Get the list of data we need to download
COPY downloads.txt .
COPY netrc /home/jovyan/.netrc
RUN python DAACDataDownload.py -dir . -f downloads.txt
RUN rm /home/jovyan/.netrc


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

WORKDIR /LPDAAC
#Format the data docs
RUN wget -O prisma_data.csv https://www.sciencebase.gov/catalog/file/get/62a91cc2d34ec53d2770f06d?f=__disk__cb%2F45%2F62%2Fcb4562caa9aaad6b4c55db13925f24b09aa7dbd3
RUN wget -O desis_data.csv https://www.sciencebase.gov/catalog/file/get/62a91cc2d34ec53d2770f06d?f=__disk__d2%2F06%2Fe4%2Fd206e4e55fd1f545bd204e0475fcc7b5b7c9410d

RUN xlsx2csv --all GHISACASIA_EO1_Hyperion_2007_001.xlsx > GHISACASIA.csv 

RUN python /LPDAAC/tag-delete.py GHISACASIA.csv
RUN python /LPDAAC/tag-delete.py GHISACONUS_2008_001_speclib.csv 
RUN python /LPDAAC/format.py

#Delete redundant data files. Consider commenting this line during debugging.
RUN rm desis_data.csv && rm prisma_data.csv && rm GHISACASIA_EO1_Hyperion_2007_001.xlsx && rm GHISACONUS_2008_001_speclib.csv && rm GHISACASIA.csv

WORKDIR /work
RUN mv /GHISA_Spectral_Visualization_App/GHISA_Visualization.ipynb .

#MAKE SURE THIS IS 555 IN PROD
RUN chmod 777 GHISA_Visualization.ipynb

