## Tips
* [Getting started](https://docs.docker.com/get-started/)
* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
* [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
* [Docker tag](https://docs.docker.com/engine/reference/commandline/tag/)

> **NB order:**  
> `HOST:CONTAINER`

## First shot
at building nginx image with a web page in it
```
mkdir task_1
cd task_1

# Create a page
# Create a Dockerfile

# Build image
docker build -t webpage .

# Run container
# NB host_port:container_port
docker run -dp 8001:80 --name webpage webpage

# Stop container
docker stop webpage

# Remove container
docker rm webpage

# Remove image
docker rmi webpage

# Actually, no need to do it in order to rebuild, simply run docker build... again

# Login into hub
docker login -u ansakoy

# Tag image
docker tag webpage ansakoy/webpage:v0.0.1

# Push to remote repo
docker push ansakoy/webpage:v0.0.1
```
## Connecting two containers
to a single host directory
```
mkdir -p ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data
cd ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data
docker run --name=centos -div ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data:/data centos
docker run --name=debian -div ~/Documents/Courses/netology/devops-netology/05/05_3/task_3/data:/data debian
# -d - detached
# -i interactive
# -v volume
docker exec -ti centos bash
echo "file from centos" > /data/file_from_centos
exit
echo "file from host" > file_from_host
docker exec -ti debian bash
```

