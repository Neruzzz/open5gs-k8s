FROM ubuntu:jammy AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install \
        make \
        g++ \
        libsctp-dev \
        lksctp-tools \
        git \
        vim \
        iproute2 \
        iptables \
        net-tools \
        ifupdown \
        iputils-ping \
        wget \
        libssl-dev \
        cmake

# Clone and build UERANSIM
RUN git clone https://github.com/aligungr/UERANSIM && \
    cd UERANSIM && git checkout tags/v3.2.6 && \
    make -j`nproc`

WORKDIR /UERANSIM/build

CMD ["sh", "-c", "tail -f /dev/null"]