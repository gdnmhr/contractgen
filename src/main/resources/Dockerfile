FROM ubuntu:latest AS build

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin apt-get install -y build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python3 libftdi-dev gperf \
                     libboost-program-options-dev autoconf libgmp-dev \
                     cmake curl cmake ninja-build g++ python3-dev python3-setuptools \
                     python3-pip autoconf gperf \
                     gcc-11 g++-11 tclsh ant default-jre swig google-perftools libgoogle-perftools-dev \
                     python3-dev uuid uuid-dev libfl-dev wget python3-orderedmultidict

WORKDIR /home/yosys
RUN mkdir tools
WORKDIR /home/yosys/tools

RUN git clone https://github.com/YosysHQ/yosys.git yosys
WORKDIR /home/yosys/tools/yosys
RUN git fetch --all --tags && git checkout v0.50
RUN git submodule update --init
RUN mkdir build
WORKDIR /home/yosys/tools/yosys/build
RUN make -j$(nproc) -f ../Makefile
RUN make install -f ../Makefile
WORKDIR /home/yosys/tools

RUN git clone https://github.com/chipsalliance/synlig synlig
WORKDIR /home/yosys/tools/synlig
RUN git fetch --all --tags && git checkout 2023-06-30-eceb24b
RUN git submodule update --init --recursive Surelog yosys yosys-f4pga-plugins UHDM-integration-tests
RUN ./build_binaries.sh
#RUN git submodule sync
#RUN git submodule update --init --recursive third_party/surelog
#RUN git submodule update --init --recursive third_party/yosys
#RUN make install
WORKDIR /home/yosys/tools

RUN git clone https://github.com/Z3Prover/z3.git z3
WORKDIR /home/yosys/tools/z3
RUN git fetch --all --tags
RUN git checkout tags/z3-4.11.2 -b z3-4.11.2-branch
RUN python3 scripts/mk_make.py
WORKDIR /home/yosys/tools/z3/build
RUN make -j$(nproc)
RUN make install
WORKDIR /home/yosys/tools

RUN curl -sSL https://get.haskellstack.org/ | sh
RUN git clone https://github.com/zachjs/sv2v.git
WORKDIR /home/yosys/tools/sv2v
RUN make -j$(nproc)
RUN stack install
WORKDIR /home/yosys/tools

RUN git clone https://github.com/steveicarus/iverilog.git
WORKDIR /home/yosys/tools/iverilog
RUN sh autoconf.sh
RUN ./configure
RUN make -j$(nproc)
RUN make install
WORKDIR /home/yosys/tools

WORKDIR /home/yosys

FROM ubuntu:latest AS main

RUN groupadd -g 1002 yosys
RUN useradd yosys -u 1002 -g 1002 -m -d /home/yosys -s /bin/bash
WORKDIR /home/yosys

RUN apt update
RUN apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Berlin apt install -y \
        nano git bison flex libreadline-dev \
        libffi-dev graphviz \
        xdot python3 libftdi-dev gperf \
        libboost-program-options-dev libgmp-dev \
        curl python3-pip openjdk-21-jre-headless openjdk-21-dbg maven \
        tcl-dev

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/include /usr/local/include
COPY --from=build /usr/local/share /usr/local/share
COPY --from=build /usr/bin/z3 /usr/bin/z3
COPY --from=build /root/.local/bin/sv2v /usr/local/bin/sv2v
COPY --from=build /home/yosys/tools/synlig/image/share/yosys/plugins /usr/local/share/yosys/plugins

USER yosys

CMD ["/bin/bash"]