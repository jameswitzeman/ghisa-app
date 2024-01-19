#This small script will build the docker image and start up a container running the server.
docker system prune -f
docker build -t jupyter .
docker stop ghisa-dev && docker rm ghisa-dev
docker run -d $1 -p 80:8888 --name ghisa-dev jupyter start-notebook.py \
	--ServerApp.root_dir=/work \
	--ServerApp.token='' \
	--ServerApp.password='' \
