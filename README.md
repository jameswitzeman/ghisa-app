This repository holds a docker image which runs a version of the GHISA visualization app on a jupyter server.
Please note that hosting this container requires having a username and password for nasa earth data services. The container will automatically download
LPDAAC data, but only if there is a .netrc file in here with the dockerfile which has valid login info.