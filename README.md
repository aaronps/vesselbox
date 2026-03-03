# vesselbox

Containerized VPS-like environments.

The idea is to run docker images where users or developers connects to the running
container using ssh and can use like if it were a remote server, keeping installed
packages and running systemd (other init system may be added later). For example,
if the user install something using `apt` or `dnf` it will be there next time the
container restarts.

You could use this to create environments for others on kubernetes, and keep the data
on PVC, or just run several environments on a single docker compose but each user is 
separated.

> **Note**: The containers are started with the `SYS_ADMIN` capability and we remove
> extra capabilities before running `systemd`.

## Build

### 1. Build vesselbox image

    docker buildx build docker/vesselbox \
        --progress=plain \
        -t vesselbox/vesselbox:latest

### 2. Create a custom builder

You need a custom builder because we don't generate a container image for the
environments. This is a basic example, you may want to read official documentation about that:

    docker buildx create --name custom --driver=docker-container

### 3. Create the environment image

On this example, the result is saved on `dist/ubuntu24.04.tar` (uncompressed)

Basic command:

    docker buildx build \
        --builder=custom \
        --output type=tar,dest=dist/ubuntu24.04.tar \
        --progress=plain \
        docker/ubuntu24.04

You can customize the Ubuntu 24.04 sample using build-time arguments:

- **REGISTRY**: Use an alternative registry instead of default docker hub
- **UBUNTU_MIRROR**: Use an alternative Ubuntu mirror, only the domain name is replaced
- **TZ**: Set the `TZ` environment variable on the container, defaults to `UTC`, this value might affect the final output package.
- **LANG**: Set the `LANG` environment variable on the container, defaults to `C.UTF8`, this value might affect the final output package.

Example with extra arguments:

    docker buildx build ... \
        --build-arg REGISTRY=my.hub.mirror \
        --build-arg UBUNTU_MIRROR=my.ubuntu.mirror \
        --build-arg TZ=GMT

## Use

### Using docker compose

You can see the example on the `compose/` directory. Each environment is composed of 3 parts: a volume, an initialization job and a running service.

1. Initialize the volume, the command will ask you to set the new root password.

       docker compose run --rm -it init-ubuntu2404

2. Start the service

       docker compose up -d


## Roadmap

- [ ] Add debian environments
- [ ] Add alma/rocky environments
- [ ] Helm chart / raw manifests

## TODO

- [ ] Write Initial Roadmap
- [ ] Write initial TODO
- [ ] The ssh host keys should be created for each environment on the init-volume, but decide which
strategy would be best for all the different environments, maybe config or file locations differ.
- [ ] Is an alpine environment usefull? (but it doesn't use systemd)
