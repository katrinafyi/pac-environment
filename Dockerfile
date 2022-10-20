FROM ocaml/opam:ubuntu-22.04-ocaml-4.09

USER root
# Enable local APT mirrors for faster downloads
RUN sed -i \
  -e 's|http://archive|mirror://mirrors|' -e 's|/ubuntu/|/mirrors.txt|' \
  -e 's|http://security|mirror://mirrors|' /etc/apt/sources.list

# Install system dependencies
RUN apt-get update && apt-get install -y python3 libgmp-dev yasm m4 wget \
  libcurl4-gnutls-dev pkg-config zlib1g-dev cmake ninja-build

# Compile latest capstone 5 (required by radare2)
# note: we must use next branch otherwise older capstone4 is built
RUN git clone -b next https://github.com/capstone-engine/capstone.git \
  && cd capstone && ./make.sh && ./make.sh install

# Compile radare2, not available in ubuntu 22.04 repositories
RUN git clone https://github.com/radareorg/radare2 \
  && radare2/sys/install.sh

# Compile LLVM with RTTI and EH enabled for alive2 (very slow)
RUN git clone --depth 1 https://github.com/llvm/llvm-project.git llvm \
  && cd llvm && mkdir build && cd build \
  && cmake -GNinja -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_EH=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PROJECTS="llvm;clang" ../llvm \
  && ninja && ninja install

# Compile and install alive2
USER root
RUN apt-get install -y re2c
RUN git clone https://github.com/AliveToolkit/alive2.git \
  && cd alive2 && mkdir build && cd build \
  && cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. \
  && ninja && ninja install

RUN apt-get install -y llvm-14

USER opam

# Download opam dependency files for ASLi and bap, and install
RUN wget -O asli.opam https://raw.githubusercontent.com/UQ-PAC/asl-interpreter/partial_eval/asli.opam \
  && wget -O bap.opam https://raw.githubusercontent.com/UQ-PAC/bap/a64-lifter-plugin/opam/opam \
  && opam install --deps-only ./bap.opam ./asli.opam \
  && opam install ocaml-lsp-server

