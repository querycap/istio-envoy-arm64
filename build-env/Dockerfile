FROM debian:buster as gn

RUN set -eux; \
    \
    apt-get update; \
    apt-get install -qqy --no-install-recommends \
        ca-certificates git \
        clang python ninja-build \
        libclang-dev libc++-dev \
        ; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN set -eux; \
    \
    git clone https://gn.googlesource.com/gn; \
    cd gn; \
    git checkout 9a0496a7; \
    python build/gen.py; \
    ninja -v -C out; \
    out/gn_unittests; \
    mkdir -p /gn; \
    cp /tmp/gn/out/gn /gn/gn; \
    /gn/gn --version;

FROM debian:buster as hsdis

RUN set -eux; \
    \
    apt-get update; \
    apt-get install -qqy --no-install-recommends \
        ca-certificates git \
        build-essential apt-utils libtool  \
        wget curl unzip \
        automake cmake make autoconf virtualenv \
        python ninja-build g++ \
        openjdk-11-jdk software-properties-common \
        ;

# build hsdis-<arch>.so
# see https://metebalci.com/blog/how-to-build-the-hsdis-disassembler-plugin-on-ubuntu-18/
RUN set -eux; \
    \
    echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list; \
    apt-get update; \
    \
    case $(uname -m) in \
        x86_64) \
            export ARCH=amd64; \
            export TARGETARCH=amd64; \
        ;; \
        aarch64) \
            export ARCH=aarch64; \
            export TARGETARCH=arm64; \
        ;; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac; \
    \
    mkdir -p /tmp/jdk && cd /tmp/jdk;  \
    apt-get source openjdk-11-jdk-headless; \
    cd $(ls -b | head -1)/src/utils/hsdis; \
    \
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.gz; \
    tar -xzf binutils-2.32.tar.gz; \
    export BINUTILS=binutils-2.32; \
    sed -i -e 's/app_data->dfn = disassembler(native_bfd)/app_data->dfn = disassembler(bfd_get_arch(native_bfd),bfd_big_endian(native_bfd),bfd_get_mach(native_bfd),native_bfd)/g' hsdis.c;\
    make all64; \
    \
    mkdir -p /hsdis; \
    cp build/linux-${ARCH}/hsdis-${ARCH}.so /hsdis/hsdis-${ARCH}.so;

# todo switch back official when bazel upgraded to 3.4.0
FROM busybox AS bazel-bin
# ADD https://github.com/bazelbuild/bazelisk/releases/download/v1.6.1/bazelisk-linux-amd64 /bazel/bazel
ADD https://github.com/Tick-Tocker/bazelisk-arm64/releases/download/arm64/bazelisk-linux-arm64 /bazel/bazel

FROM golang:1.15 AS bazel

COPY --from=bazel-bin /bazel/bazel /usr/local/bin/bazel

RUN chmod +x /usr/local/bin/bazel && bazel --version
RUN go get github.com/bazelbuild/buildtools/buildifier
RUN go get github.com/bazelbuild/buildtools/buildozer

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN set -eux; \
    \
    apt-get update; \
    apt-get install -y \
    build-essential \
    apt-utils \
    unzip \
    git \
    make \
    cmake \
    automake \
    autoconf \
    libtool \
    virtualenv \
    python \
    vim \
    g++ \
    wget \
    ninja-build \
    curl \
    lsb-core \
    openjdk-11-jdk \
    software-properties-common \
    ; \
    rm -rf /var/lib/apt/lists/*;

# bazel
COPY --from=bazel /usr/local/bin/bazel /usr/local/bin/bazel
COPY --from=bazel /go/bin/buildifier /usr/local/bin/buildifier
COPY --from=bazel /go/bin/buildozer /usr/local/bin/buildozer

# gn
COPY --from=gn /gn/gn /usr/local/bin/gn

# hsdis-<arch>.so
COPY --from=hsdis /hsdis/* /usr/lib/jvm/java-11-openjdk-${TARGETARCH}/lib/server/
COPY --from=hsdis /hsdis/* /usr/lib/jvm/java-11-openjdk-${TARGETARCH}/lib/

ENV LLVM_VERSION=9.0.0
ENV LLVM_PATH=/usr/lib/llvm-9

RUN set -eux; \
    \
    case $(uname -m) in \
        x86_64) export LLVM_RELEASE=clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-18.04;; \
        aarch64) export LLVM_RELEASE=clang+llvm-${LLVM_VERSION}-aarch64-linux-gnu;; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac; \
    \
    curl -LO  "https://releases.llvm.org/${LLVM_VERSION}/${LLVM_RELEASE}.tar.xz"; \
    tar Jxf "${LLVM_RELEASE}.tar.xz"; \
    mv "./${LLVM_RELEASE}" ${LLVM_PATH}; \
    chown -R root:root ${LLVM_PATH}; \
    rm "./${LLVM_RELEASE}.tar.xz"; \
    \
    echo "${LLVM_PATH}/lib" > /etc/ld.so.conf.d/llvm.conf; \
    ldconfig; 

ENV PATH="${LLVM_PATH}/bin:${PATH}"
