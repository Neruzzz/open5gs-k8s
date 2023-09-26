ARG ROOT_CONTAINER=registry.gitlab.bsc.es/ppc/software/open5gs/base-open5gs-kubernetes
FROM $ROOT_CONTAINER

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

# Get open5gs code and install
RUN git clone --recursive https://github.com/open5gs/open5gs && cd open5gs && \
    git checkout main && meson build --prefix=`pwd`/install && \
    ninja -C build && cd build && ninja install

CMD ["sh", "-c", "tail -f /dev/null"]