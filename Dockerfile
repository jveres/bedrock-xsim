FROM ubuntu:18.04 as build

# Setup build-only environment vars
ARG DOCKER_BUILD
ENV DOCKER_BUILD $DOCKER_BUILD
ARG SQLITE_ID="1d984722"

# Install some dependencies
RUN apt-get update && apt-get -y install software-properties-common && add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get update
RUN apt-get install -y git build-essential gcc-9 g++-9 libpcre++-dev zlib1g-dev wget

# Get Sqlite src
RUN wget https://www.sqlite.org/src/tarball/1d984722/SQLite-${SQLITE_ID}.tar.gz
RUN tar xzf SQLite-${SQLITE_ID}.tar.gz

# Clone Bedrock src
RUN git clone https://github.com/Expensify/Bedrock.git /src

# Build it
WORKDIR /src
# Add extensions
COPY core_init.c .
RUN cat /SQLite-${SQLITE_ID}/ext/misc/series.c \
        /SQLite-${SQLITE_ID}/ext/misc/percentile.c \
        /SQLite-${SQLITE_ID}/ext/misc/regexp.c \
        /SQLite-${SQLITE_ID}/ext/misc/uuid.c \
        core_init.c >> libstuff/sqlite3.c

RUN sed -i. 's/-DSQLITE_ENABLE_SESSION/-DSQLITE_AMALGAMATION -DSQLITE_EXTRA_INIT=core_init -DSQLITE_ENABLE_SESSION -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_GEOPOLY -DSQLITE_ENABLE_DBSTAT_VTAB/' Makefile
RUN make

# Run tests
WORKDIR /src/test
RUN ./test -threads 8
WORKDIR /src/test/clustertest
RUN if [ "$DOCKER_BUILD" ]; then echo "Skipping cluster tests on Docker Hub"; else ./clustertest -threads 8; fi

# Prepare artifacts
COPY start.sh /usr/local/bin/
RUN apt-get install -y busybox
RUN mkdir -p /rootfs
RUN cp /src/bedrock /usr/local/bin/
RUN ldd /usr/local/bin/bedrock \
    /lib/x86_64-linux-gnu/libnss*.so.* \
    | grep -o -e '\/\(usr\|lib\)[^ :]\+' \
    | sort -u | tee /rootfs.list

RUN echo "/bin/busybox" >> /rootfs.list

RUN cat /rootfs.list | xargs strip

RUN chmod +x /usr/local/bin/start.sh
RUN echo "/usr/local/bin/start.sh" >> /rootfs.list
RUN echo 'hosts: files dns' > /etc/nsswitch.conf
RUN echo /etc/nsswitch.conf >> /rootfs.list

RUN cat /rootfs.list | tar -T- -cphf- | tar -C /rootfs -xpf-

RUN cat /rootfs.list

FROM scratch
COPY --from=build /rootfs/ /
ENTRYPOINT ["/usr/local/bin/start.sh"]
