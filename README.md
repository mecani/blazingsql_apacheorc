# Docker container with BlazingSQL and Apache ORC
Docker container with blazing sql and apache ORC from nvidia/cuda working in python with Conda. 

# Requirements
- Latest Nvidia driver installed

## Setup nvidia container runtime
To be able to use this docker container, install nvidia-docker2 first. 

Source: https://nvidia.github.io/nvidia-container-runtime/

````shell script
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update

sudo apt-get install nvidia-docker2
````

## Build
To build the docker image use the following command:
```shell script
nvidia-docker build . -t blazingsql_orc
```

### Run the image

to launch the docker, open a terminal at the root of this project and start it with docker-compose:

```shell script
nvidia-docker run -i -t -p 8888:8888 -p 8787:8787 -p 8786:8786 -v $(pwd):/blazingsql/project blazingsql_apacheorc /bin/bash -c "/entrypoint.sh"
```

A jupyter notebook will be accessible at this address:
```
http://localhost:8888
```

The jupyter token is :
```
blazingsql
```