# LLFI (LLVM 3.4) fault-injection toolchain + this replication package.
#
# The fault injector LLFI is pinned to LLVM/clang 3.4 on Ubuntu 14.04, which is
# awkward to build on a modern host; this image reproduces the exact working
# environment. Building LLVM 3.4 from source takes roughly 30-60 minutes on a
# many-core machine and needs ~8 GB of RAM.
#
# Steps for a reviewer:
#   bash docker/downloads/fetch.sh          # download LLVM/clang/LLFI sources (~56 MB)
#   docker build -t anonymous-sdc-artifact .
#   docker run --rm -it anonymous-sdc-artifact           # lands in /artifact
# Then, inside the container:
#   ./scripts/run_quick_check.sh
#
# Use --build-arg NPROC=<cores> to speed up the LLVM build.

FROM ubuntu:14.04

# 14.04 (trusty) is EOL but is still served by archive.ubuntu.com
# (old-releases.ubuntu.com does NOT carry trusty, despite common advice).
RUN printf '%s\n' \
      'deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse' \
      'deb http://archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse' \
      'deb http://archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse' \
      > /etc/apt/sources.list \
 && rm -f /etc/apt/sources.list.d/* \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential cmake python3 python3-dev python3-yaml python \
      tcsh git zlib1g-dev unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /root/ws

# Source archives, fetched on the host by docker/downloads/fetch.sh
# (COPYed rather than downloaded here, because 14.04's old TLS cannot fetch
# some modern HTTPS endpoints).
COPY docker/downloads/llvm-3.4.src.tar.gz  /tmp/
COPY docker/downloads/clang-3.4.src.tar.gz /tmp/
COPY docker/downloads/LLFI-master.zip      /tmp/

RUN tar xzf /tmp/llvm-3.4.src.tar.gz \
 && tar xzf /tmp/clang-3.4.src.tar.gz \
 && mv llvm-3.4 llvm \
 && mv clang-3.4 llvm/tools/clang \
 && unzip -q /tmp/LLFI-master.zip \
 && mv LLFI-master LLFI \
 && rm -f /tmp/*.tar.gz /tmp/*.zip

# Build LLVM 3.4 + clang WITH RTTI (an LLFI requirement), X86 only, Release.
ARG NPROC=8
RUN mkdir -p llvm-build && cd llvm-build \
 && cmake ../llvm \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_REQUIRES_RTTI=1 \
      -DLLVM_TARGETS_TO_BUILD=X86 \
      -DLLVM_ENABLE_TERMINFO=OFF \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
 && make -j${NPROC}

RUN cd LLFI \
 && python3 ./setup \
      -LLVM_DST_ROOT /root/ws/llvm-build \
      -LLVM_SRC_ROOT /root/ws/llvm \
      -LLFI_BUILD_ROOT /root/ws/llfi \
      -LLVM_GXX_BIN_DIR /root/ws/llvm-build/bin \
      --no_gui

ENV LLFI_ROOT=/root/ws/llfi \
    CLANGXX=/root/ws/llvm-build/bin/clang++ \
    LLFI_BUILD_ROOT=/root/ws/llfi \
    LLVM_SRC_ROOT=/root/ws/llvm \
    LLVM_DST_ROOT=/root/ws/llvm-build \
    PATH=/root/ws/llfi/bin:/root/ws/llfi/tools:/root/ws/llvm-build/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# The replication package itself.
COPY . /artifact
RUN rm -rf /artifact/docker/downloads/*.tar.gz /artifact/docker/downloads/*.zip
WORKDIR /artifact
CMD ["bash"]
