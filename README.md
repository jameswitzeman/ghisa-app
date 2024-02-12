This repository holds a docker image which runs a version of the GHISA visualization app on a jupyter server.
Please note that hosting this container requires having a username and password for nasa earth data services. The container will automatically download
LPDAAC data, but only if there is a .netrc file in here with the dockerfile which has valid login info.


Running the start.sh bash script will automatically prune unused docker containers and images, build a docker image, and launch a Docker container with the
required data ready. If the container is started via this script, it will boot up a Jupyter notebook on the 80 port which allows visualization
of the data. NOTE: This jupyter web-app will be replaced by a more robust visualization tool.