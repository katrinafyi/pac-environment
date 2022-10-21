FROM ocaml/opam:ubuntu-20.04-ocaml-4.09

ARG llvm=llvm-14.0.6+rtti+eh
ARG llvm_url=https://github.com/katrinafyi/pac-environment/releases/download/llvm/${llvm}.tar.gz

USER root
# Enable local APT mirrors for faster downloads
RUN sed -i \
  -e 's|http://archive|mirror://mirrors|' -e 's|/ubuntu/|/mirrors.txt|' \
  -e 's|http://security|mirror://mirrors|' /etc/apt/sources.list

# Install system dependencies
RUN apt-get update && apt-get install -y python3 libgmp-dev yasm m4 wget \
  libcurl4-gnutls-dev pkg-config zlib1g-dev cmake ninja-build g++-10 \
  radare2 z3 libz3-dev re2c

# Use pre-compiled llvm build
ADD ${llvm_url} .
RUN tar xf $llvm.tar.gz && cp -rv --no-clobber $llvm/. /usr/local

USER opam

# Compile and install alive2
#RUN git clone https://github.com/AliveToolkit/alive2.git \
#  && cd alive2 && mkdir build && cd build \
#  && which g++-10 gcc-10 \
#  && CXX=`which g++-10` CC=`which gcc-10` cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_TV=1 .. \
#  && ninja

# Download opam dependency files for ASLi/bap, and install
ADD --chown=opam https://raw.githubusercontent.com/UQ-PAC/asl-interpreter/partial_eval/asli.opam ./asli.opam
ADD --chown=opam https://raw.githubusercontent.com/UQ-PAC/bap/a64-lifter-plugin/opam/opam ./bap.opam
RUN eval `opam env` \
  && opam install --deps-only ./bap.opam ./asli.opam \
  && opam install ocaml-lsp-server

