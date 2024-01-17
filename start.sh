#This small script will build the docker image and start up a container running the server.
docker build -t jupyter .
docker run -d --rm -p 80:8888 --name ghisa-dev jupyter start-notebook.py \
	--ServerApp.root_dir=/work \
	--ServerApp.token='' \
	--ServerApp.password='' \
