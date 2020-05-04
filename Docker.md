## Docker

### What is Docker

    Docker is a platfor,/ecosys around creatig/running container

    Ecosystem
```
        Docker Client
        Docker Machine
        Docker Hub
        Docker Server
        Docker compose
        Docker images
```

    Image

        Single file with deps and config to run a prgm

    Container
        instance of image / runs a progm (Start cpmmand)

        It has process / kerner (shard) / +
        Portion of each [ HD , N/W, RAM, CPU ]


    Containers were possible by Namespacing/control group by linux only.

    When installing docker, it has linux VM which makes this possible.


### Why is Docker

    Make easy to install / run s/w wihout worrying dependencies

### Docker S/w has 2 parts

Docker Client (CLI)

    Tool where we will work

Docker Server Daemon

    Tool which will create image/run container. We wont work directly


## Manipulation of Containers

Creating / Running Container from image

docker run hello-world

docker - CLI / client
run - > create, run container
hello-world - name of the image to use on the container

### overiding default run command

docker run busybox ls

i.e 4th param

### Listing running containers

docker ps

All containers created - docker ps --all 

### Lifecycle of container

docker run = docker create + docker start

create - will only put the image in HD  - this will return a hash id

start - > run the startup comd of image  - need the id returned from create

```
docker create hello-world

docker start -a 7y797987997

-a helps to wait for output in pgm and dispay in our terminal. else we dnt see anything however the pgm run
```

### Restarting Stopped Containers

docker start -a 98989898 {id of container which was closed}

but default command cant be changed. restrat with same default command.

### Removing Stopped Containers

docker system prune

but wont remove from docker cache

### Retrieving Log output

docker logs containerid // only logs ouput of thjat container. usefull when -a not usded when start of docker

### Stopping container

docker stop container - linear SIGTERM - 10 sec if not responded fallback to kill

docker kill container - immediate SIGKILL

### Multi command containers

pass a command to a running container

docker exec -it <containerId> command

-it means input

-i turning ur terminal to attach to STDIN
-t turning ur termunal for STDOUT

### Getting command prompt

pass sh via exec -it.

docker exec -it <containerId> sh

docker run -it <containerId> sh

To exit of docker shell,

Control + C / exit

### Containers are in isolation and they dont share anything in memory

### Creating Docker Images

1. Dockerfile - config file how container should behave
2. Docker client - CLI pass the config to server
3. Docker Server - Server checkj the config and create the image
4. Usable Image - 

**Flow**

1. Specify a base image
2. run some commands to install addiontal prgm
3. specify a command to run it on container start

### EG - Creating a docker image redis-server

create any folder in HD and cd into

Create a dcokerfile by name Dockerfile

```
# Use base image
FROM alpine


# install deps
RUN apk add --update redis

# tell image what to do when run on container
CMD ["redis-server"]
```

and then

```
docker build .

docker run <ContID>
```

### Explaining the dockerfile

FROM -> Specify use existing docier as base

RUN -> used to run some command

CMD -> command to run when on container

```
Consider, Open chrom on a computer without OS.
first we need to install OS and   - FROM
go to google.chrome
download
execute installer -- RUN Portion
run chrome -CMD Portion
```

Likewise, 
alpine is base linux distribution - which has some use for redis

So, the above dockerfile means,

```
Install alpine
Intall redis on that distribution 
and run on container
```

### docker build .

docker build -> pass dockerfile to CLI
. -> pass the current context where thje build etc r happeing

FROM -> output is a custom image from a base image FS snapshot

RUN -> create a temp container and run those commands and create updated snapshot and delete that container too.

CMD -> create a temp containr and run that CMD command on that updated snapshopt and create final image.

If rerun on `docker build .` on terminal, docker will refer to build cache and do it. But **if any line change or order of lines changed, it will build again**

### Tagging a build image

docker build -t nameoftag .

nameoftag => dockerid/nameofproj:version

i.e leslielees/redis:latest

```
docker build -t leslielees/redis:la
test .

# by default its latest. so to run,
docker run leslielees/redis
```

### Node-Express Example

When we do base image, choose somehting where npm installed.

i.e alpine dont have npm.

so, instead of alpine choose node base image. alpine are compact distribution, check in hub.docker.com for alpine version of node.

i.e node:alpine

```
FROM node:alpine

RUN npm intall

CMD ["npm","start]
```

But wont work cos it cant find package.json or any files as node will be inside container.

So, to make work, 

use, 

`COPY ./ ./` before `RUN` . So CLI will copy the local folders to containers

first ./ refer local HDD
second ./ refer to path in container

Still, localhost port is not same docker ports.

we need to map while we run it.

docker run -p 80:3000 leslielees/nodeexp

80 - localhostport
3000 - docker port on which app is running

### Workdir

So, on the container, when we do via COPY that places all files in root of the file system inside container which is not safe.

So, by giving WORKDIR /path/here makes the COPY places inside that path.

That makes the file as

```
FROM node:alpine

WORKDIR /usr/app

COPY ./ ./

RUN npm intall

CMD ["npm","start]
```

To run and check

```
docker build -t leslielees/nodeexp .

docker run -p 80:3000 <contid>
```

### Avoiding unwanted build

The above will run npm install for any changes in dir which is not requires.
But only packagejson, its required.

So, we rewrite as
```
COPY ./package.json ./
RUN npm install
COPY ./ ./
```

### Docker Compose
another CLI from docker

Used to start multiple containers at same time

helps automating long args in docker run.

Useful to bridge 2 different isolated containers.

Syntax:

version:'3' //version of compose 
services: // containers

```
docker compose up //docker run image

docker compose up --build // docker build and ducker run together
```

### Running in background and stopping

docker run `-d` image

This will run in background

like wise,

`docker-compose up -d` will run all containers in compose in background

`docker-compose down` will stop all containers in composed.

### Restart docker containers

in compose files, we can specify one of 4 restart policies

```
services: 
  redis-server:
    image: 'redis'
    restart: always
  node-app:
    restart: always  // "no", always, on-failure, unless-stopped	
    build: .
    ports:
      - "3000:8080"
```

`docker-compose ps` to show status of docker composed containers

### Workflow

EG: Lets make an app and push to git and depoy to AWS via Travis CI

**Docker Volumes**

`-v flag`

Docker volume help to map local folder to container

`-v $(pwd):/usr/app/frontendpp`

if we need to retain a local folder in container, then bookmark path first b4 mapping

`-v /usr/app/frontend/node_modules`

so, 

`docker run -it -p 3000:3000 -v /usr/app/frontend/node_modules -v $(pwd):/usr/app/frontendpp leslielees/frontend`
