# vesselbox

Lightweight, containerized VPS-like environments.

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

    docker buildx build . -f docker/vesselbox/Dockerfile -t vesselbox/vesselbox:latest

### 2. Create a custom builder

You need a custom builder because we don't generate a container image for the
environments. This is a basic example, you may want to read official documentation about that:

    docker buildx create --name custom --driver=docker-container

### 3. Create the environment image

On this example, the result is saved on `dist/ubuntu24.04.docker.tar` (layers are gzip compressed)

Basic command:

    docker buildx build \
        --builder=custom \
        --output type=docker,dest=dist/ubuntu24.04.docker.tar,compression=gzip \
        -t vesselbox/ubuntu:24.04 \
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

Example with registry and rootfs outputs, you can mix any kind of outputs:

    docker buildx build ... \
        --output type=registry,registry.insecure=true,name=host.docker.internal:5000/vesselbox/ubuntu:24.04,compression=gzip \
        --output type=tar,dest=dist/ubuntu24.04.rootfs.tar

## Use

### Using docker compose

You can see the example on `compose.yaml` file, it uses a internal registry.

1. When using the internal registry, start it

       docker compose up -d registry

2. Initialize the volume, will ask to set the new root password.

       docker compose run --rm --entrypoint init-volume.sh debian133

3. Start the service or run directly.

       docker compose up -d debian133

       docker compose run --rm --service-ports debian133

4. You can stop the container within itself using `halt`, `reboot` and `shutdown`

### Using docker

Using docker requires more commands:

1. Create a volume

        docker volume create the-volume

2. Initialize the volume, will ask you for the new root password

        docker run --rm -it --name test \
            --stop-signal SIGRTMIN+3 \
            -e container=docker \
            --cap-add sys_admin \
            -v the-volume:/data \
            -v ./dist:/images \
            --entrypoint init-volume.sh \
            vesselbox/vesselbox \
            --image=/images/debian13.3.docker.tar

3. Run it

        docker run --rm -it --name test \
            --stop-signal SIGRTMIN+3 \
            -e container=docker \
            --cap-add sys_admin \
            -v the-volume:/data \
            vesselbox/vesselbox

## Features

- Tested the following image environments:
    - Debian: 13.3 and 12.8
    - Ubuntu: 24.04 and 22.04
    - Rockylinux: 10.1 and 9.7
- Base image can be a rootfs file, a docker image file or pulled directly from the registry.    

## Roadmap

- [ ] Helm chart / raw manifests
- [x] Add debian environments (13.3 and 12.8)
- [x] Add alma/rocky environments
- [x] Use OCI artifacts and registries for environment base image

## TODO

- [ ] almalinux 10.1 doesn't work properly, is work in progress
- [x] Consider /proc/kmsg and `kernel.dmesg_restrict = 0`
    - [ ] Write doc about `kernel.dmesg_restrict=1`, and wsl.
- [ ] Is an alpine environment useful? (it doesn't use systemd, openrc works different)
- [ ] Create vesselbox script
- [ ] Decide what to do with systemd stop signal (SIGRTMIN+3)
- [ ] Check why Debian 13.3 dbus fails now with `--securebits=+noroot` in entrypoint.sh (before was good)
