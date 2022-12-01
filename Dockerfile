FROM ocaml/opam:ubuntu-20.04-ocaml-4.09


USER root
# Enable local APT mirrors for faster downloads
RUN sed -i \
  -e 's|http://archive|mirror://mirrors|' -e 's|/ubuntu/|/mirrors.txt|' \
  -e 's|http://security|mirror://mirrors|' /etc/apt/sources.list

# Install system dependencies
RUN apt-get update && apt-get install -y python3 libgmp-dev yasm m4 wget \
  libcurl4-gnutls-dev pkg-config zlib1g-dev cmake ninja-build g++-10 \
  radare2 z3 libz3-dev llvm-12-dev \
  re2c

USER opam

# Install opam dependencies for ASLi/bap
# Note: system-install of llvm-12-dev will be used by bap.
ADD --chown=opam https://raw.githubusercontent.com/UQ-PAC/asl-interpreter/partial_eval/asli.opam ./asli.opam
ADD --chown=opam https://raw.githubusercontent.com/UQ-PAC/bap/a64-lifter-plugin/opam/opam ./bap.opam
RUN eval `opam env` \
  && opam install --deps-only ./bap.opam ./asli.opam \
  && opam install ocaml-lsp-server


# Local LLVM build for alive2 only
# ARG llvm=llvm-project-15.0.3+rtti
# ARG llvm_url=https://github.com/katrinafyi/pac-environment/releases/download/llvm/${llvm}.tar.gz
#
# # Use pre-compiled llvm build
# ADD --chown=opam ${llvm_url} .
# RUN tar xf $llvm.tar.gz
#
# # Compile and install alive2 using local llvm+rtti
# RUN git clone https://github.com/AliveToolkit/alive2.git \
#   && cd alive2 && mkdir build && cd build \
#   && which g++-10 gcc-10 \
#   && CXX=`which g++-10` CC=`which gcc-10` cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_PREFIX_PATH=~/$llvm -DBUILD_TV=1 .. \
#   && ninja

