FROM ubuntu:14.04

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

COPY . /artifact
RUN rm -rf /artifact/docker/downloads/*.tar.gz /artifact/docker/downloads/*.zip
WORKDIR /artifact
CMD ["bash"]
