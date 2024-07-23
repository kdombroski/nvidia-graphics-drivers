# run docker build -f Dockerfile . -o artefacts

FROM ubuntu:noble AS builder

COPY . /src
WORKDIR /src

# add i386 architecture and update container
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get -y upgrade

# amd64 dependencies
RUN apt-get -y install \
	devscripts \
	debhelper \
	dpkg-dev \
	xz-utils \
	zstd \
	dkms \
	libxext6 \
	po-debconf \
	dh-modaliases \
	xserver-xorg-dev \
	libglvnd-dev \
	libkmod-dev \
	libpciaccess-dev \
	pkg-config \
	libnvidia-egl-wayland1 \
	libc6 \
	libx11-6 \
	python3

# amd64 package build
RUN dpkg-buildpackage -b --no-sign -aamd64

# i386 dependencies
RUN apt-get -y install \
	gcc-multilib \
	binutils-i686-linux-gnu \
	libxext6:i386 \
	xserver-xorg-dev:i386 \
	libglvnd-dev:i386 \
	libkmod-dev:i386 \
	libpciaccess-dev:i386 \
	libnvidia-egl-wayland1:i386 \
	libc6:i386 \
	libx11-6:i386 \
	python3:i386

# i386 package build
RUN dpkg-buildpackage -b --no-sign -ai386

# exporting artefacts (packages)
FROM scratch AS artefacts
COPY --from=builder /*.deb /
COPY --from=builder /*.ddeb /
COPY --from=builder /*.buildinfo /
COPY --from=builder /*.changes /

