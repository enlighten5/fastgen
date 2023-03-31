# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# # http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:20.04 AS base

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get -yq --no-install-recommends install tcl

RUN apt-get update -y &&  \
    apt-get -y install wget python3 python3-dev python3-pip python3-setuptools apt-transport-https \
    libboost-all-dev texinfo \
    lsb-release zip llvm-dev cmake software-properties-common autoconf curl zlib1g-dev flex bison git ragel

RUN apt-get install -y cargo libpixman-1-dev cmake g++ git ninja-build\
     python3-pip zlib1g-dev python2 pkg-config libglib2.0-dev
RUN pip3 install lit
RUN pip3 install jinja2
RUN pip install jinja2

RUN apt-get install clang-12 clang++-12 libc++-12-dev libc++abi-12-dev -y

#install cargo
#RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

#install protobuf
#RUN wget https://apt.llvm.org/llvm.sh && ct clone https://github.com/xiph/vorbis.githmod +x llvm.sh && ./llvm.sh 9
#RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 12
#RUN ln -s /usr/bin/llvm-config-12 /usr/bin/llvm-config
#RUN ln -s /usr/bin/clang-12 /usr/bin/clang
#RUN ln -s /usr/bin/clang++-12 /usr/bin/clang++

RUN git clone https://github.com/protocolbuffers/protobuf.git /protobuf  && \
    cd /protobuf && \
    git checkout tags/v21.12 && \
    git submodule update --init --recursive && \
    unset CFLAGS && \
    unset CXXFLAGS && \
    ./autogen.sh && \
    ./configure  && \
   # ./configure  && \
    make -j && \
    make install && \
    ldconfig

RUN git clone https://github.com/Z3Prover/z3.git /z3 && \
		cd /z3 && git checkout z3-4.8.7 && mkdir -p build && cd build && \
		cmake .. && make -j && make install
RUN ldconfig

WORKDIR /out
RUN cd /out && wget https://jigsaw.cs.ucr.edu/seeds.tar.gz && tar xvf seeds.tar.gz

WORKDIR /src
RUN cd /src && wget http://www.math.utah.edu/~mayer/linux/nbench-byte-2.2.3.tar.gz && tar xvf nbench-byte-2.2.3.tar.gz && cp -r nbench-byte-2.2.3 nbench_native

RUN pip install xlsxwriter pycrypto
#install tcmallo
# RUN git clone https://github.com/gperftools/gperftools.git /gperftools && \
#     cd /gperftools && \
#     unset CFLAGS && \
#     unset CXXFLAGS && \
#     ./autogen.sh && \
#     ./configure  && \
#     #./configure && \
#     make -j && \
#     make install && \ 
#     ldconfig

#install AFL++
#RUN git clone  https://github.com/AFLplusplus/AFLplusplus.git /afl && \
#    cd /afl && \
#    git checkout f41aafa4f7aa446c3cb1cbe6d77364cf32a6c6cb && \
#    unset CFLAGS && \
#    unset CXXFLAGS && \
#    AFL_NO_X86=1 PYTHON_INCLUDE=/ make -j && make install && \
#    make -C examples/aflpp_driver && \
#    cp examples/aflpp_driver/libAFLDriver.a /


# RUN rm -rf /usr/local/include/llvm && rm -rf /usr/local/include/llvm-c
# RUN rm -rf /usr/include/llvm && rm -rf /usr/include/llvm-c
# RUN ln -s /usr/lib/llvm-6.0/include/llvm /usr/include/llvm
# RUN ln -s /usr/lib/llvm-6.0/include/llvm-c /usr/include/llvm-c
# build kirenenko
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- --default-toolchain=1.61.0 -y
# ENV PATH="/root/.cargo/bin:${PATH}"
# RUN apt-get -y install libc++-dev libc++abi-dev
# RUN git clone https://github.com/r-fuzz/fastgen.git /symsan
# RUN cd /symsan && \
#     unset CFLAGS && \
#     unset CXXFLAGS && \
#     ./build/build.sh


# RUN git clone https://github.com/chenju2k6/build-programs.git /src/build-programs
# RUN cd /src/build-programs && ./build_symsan.sh
WORKDIR /src
RUN wget https://www.cs.ucr.edu/~zqi020/fuzzbench_program.tar.gz && \
    mkdir build-programs-native && tar xvf fuzzbench_program.tar.gz -C build-programs-native
COPY docker_key /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
RUN apt-get install vim -y

FROM base AS symcc
# RUN git clone https://github.com/eurecom-s3/symcc.git /symcc
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    git clone git@github.com:bitsecurerlab/symcc.git /symcc
# RUN git clone git@github.com:bitsecurerlab/symcc.git /symcc
# remove one concrete flag check for clb
COPY no_check_flag.patch /
RUN cd /symcc && patch -p1 < /no_check_flag.patch
RUN cd /symcc && git submodule update --init && mkdir build && cd build && \
     cmake -G Ninja -DQSYM_BACKEND=ON ../ && ninja all

# build symcc no path negation version
RUN git clone git@github.com:bitsecurerlab/symcc.git /symcc_no_negate
COPY no_check_flag.patch /
RUN cd /symcc_no_negate && patch -p1 < /no_check_flag.patch
RUN cd /symcc_no_negate && git submodule update --init
COPY symcc_nosolving.patch /src
RUN cd /symcc_no_negate && patch -p1 < /src/symcc_nosolving.patch
# COPY print_constraint.patch /src
# RUN cd /symcc_no_negate/ && patch -p1 < /src/print_constraint.patch
RUN cd /symcc_no_negate && mkdir build && cd build && \
     cmake -G Ninja -DQSYM_BACKEND=ON ../ && ninja all
# RUN cd /src && wget https://github.com/Kitware/CMake/releases/download/v3.24.0-rc1/cmake-3.24.0-rc1-linux-x86_64.tar.gz && tar xvf cmake-3.24.0-rc1-linux-x86_64.tar.gz
# RUN git clone --depth 1 https://github.com/llvm/llvm-project.git /llvm-project
# RUN mkdir -p /src/libcxx_symcc && cd /src/libcxx_symcc/ && \ 
#     SYMCC_REGULAR_LIBCXX=1 SYMCC_NO_SYMBOLIC_INPUT=1  /src/cmake-3.24.0-rc1-linux-x86_64/bin/cmake -G Ninja /llvm-project/llvm \
#     -DLLVM_ENABLE_PROJECTS="libcxx;libcxxabi" \
#     -DLLVM_TARGETS_TO_BUILD="X86" \
#     -DLLVM_DISTRIBUTION_COMPONENTS="cxx;cxxabi;cxx-headers" \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_INSTALL_PREFIX=/src/libcxx_symcc/install \
#     -DCMAKE_C_COMPILER=/symcc/build_simple/symcc \
#     -DCMAKE_CXX_COMPILER=/symcc/build_simple/sym++ && SYMCC_REGULAR_LIBCXX=1 SYMCC_NO_SYMBOLIC_INPUT=1 ninja distribution && SYMCC_REGULAR_LIBCXX=1 SYMCC_NO_SYMBOLIC_INPUT=1 ninja install-distribution
# FROM base AS symqemu
RUN git clone https://github.com/eurecom-s3/symqemu.git /symqemu
COPY symqemu_vanilla.patch /src
RUN cd /symqemu && git checkout a48e41986373b923fb706b67d1da3e5b87786780 && patch -p1 < /src/symqemu_vanilla.patch && \
# RUN cd /symqemu && git checkout a48e41986373b923fb706b67d1da3e5b87786780 && \
    mkdir build && cd build && ../configure                                                    \
      --audio-drv-list=                                           \
      --disable-bluez                                             \
      --disable-sdl                                               \
      --disable-gtk                                               \
      --disable-vte                                               \
      --disable-opengl                                            \
      --disable-virglrenderer                                     \
      --disable-werror                                            \
      --target-list=x86_64-linux-user                             \
      --enable-capstone=git                                       \
      --symcc-source=/symcc                  \
      --symcc-build=/symcc/build && make -j
RUN cp /symqemu/build/x86_64-linux-user/symqemu-x86_64 /usr/bin/symqemu

# RUN git clone https://github.com/chenju2k6/build-programs.git /src/build-programs-native
# RUN cd /src/build-programs-native && ./build_native.sh


#RUN cd /src && git clone https://github.com/chenju2k6/cgc_programs cgc_programs5 && cd cgc_programs5 && ./build.sh


# RUN cd /src/build-programs-symsannosolve && ./build_symsan.sh


# build symqemu no path negation version
RUN ln -s /usr/bin/python2.7 /usr/bin/python
RUN rm -rf /symqemu/build && mkdir /symqemu/build
RUN cd /symqemu/build && ../configure                             \
      --audio-drv-list=                                           \
      --disable-bluez                                             \
      --disable-sdl                                               \
      --disable-gtk                                               \
      --disable-vte                                               \
      --disable-opengl                                            \
      --disable-virglrenderer                                     \
      --disable-werror                                            \
      --target-list=x86_64-linux-user                             \
      --enable-capstone=git                                       \
      --symcc-source=/symcc_no_negate                             \
      --symcc-build=/symcc_no_negate/build && make -j
RUN cp /symqemu/build/x86_64-linux-user/symqemu-x86_64 /usr/bin/symqemu_nonegate

# FROM base AS symelastic
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    git clone git@github.com:bitsecurerlab/SymElastic.git /symelastic
# RUN git clone git@github.com:bitsecurerlab/SymElastic.git /symelastic
# build symelastic with mode switch (w/ solving and w/o solving)
RUN cd /symelastic && git checkout mode_switch && mkdir build && cd build && ../configure                                         \
      --audio-drv-list=                                           \
      --disable-bluez                                             \
      --disable-sdl                                               \
      --disable-gtk                                               \
      --enable-2nd-ccache                                         \
      --disable-vte                                               \
      --disable-opengl                                            \
      --disable-virglrenderer                                     \
      --disable-werror                                            \
      --target-list=x86_64-linux-user                             \
      --enable-capstone=git                                       \
      --symcc-source=/symcc_no_negate                             \
      --symcc-build=/symcc_no_negate/build && make -j

RUN cp /symelastic/build/x86_64-linux-user/symqemu-x86_64 /usr/bin/modeswitch_nonegate

RUN rm -rf /symelastic/build && mkdir /symelastic/build
RUN cd /symelastic/build && /symelastic/configure                                                   \
      --audio-drv-list=                                           \
      --disable-bluez                                             \
      --disable-sdl                                               \
      --disable-gtk                                               \
      --enable-2nd-ccache                                         \
      --disable-vte                                               \
      --disable-opengl                                            \
      --disable-virglrenderer                                     \
      --disable-werror                                            \
      --target-list=x86_64-linux-user                             \
      --enable-capstone=git                                       \
      --symcc-source=/symcc                                       \
      --symcc-build=/symcc/build && make -j
RUN cp /symelastic/build/x86_64-linux-user/symqemu-x86_64 /usr/bin/modeswitch

# build symelastic with mode switch and clb (w/ solving and w/o solving)
RUN rm -rf /symelastic/build
RUN cd /symelastic && git checkout clb
COPY clb_config.patch /src
RUN cd /symelastic && patch -p1 < /src/clb_config.patch
RUN cd /symelastic && mkdir build && cd build && ../configure     \
      --audio-drv-list=                                           \
      --disable-bluez                                             \
      --disable-sdl                                               \
      --disable-gtk                                               \
      --enable-2nd-ccache                                         \
      --disable-vte                                               \
      --disable-opengl                                            \
      --disable-virglrenderer                                     \
      --disable-werror                                            \
      --target-list=x86_64-linux-user                             \
      --enable-capstone=git                                       \
      --symcc-source=/symcc_no_negate                             \
      --symcc-build=/symcc_no_negate/build && make -j
RUN cp /symelastic/build/x86_64-linux-user/symqemu-x86_64 /usr/bin/clb_nonegate

RUN rm -rf /symelastic/build && mkdir /symelastic/build
RUN cd /symelastic/build && /symelastic/configure                                                   \
      --audio-drv-list=                                           \
      --disable-bluez                                             \
      --disable-sdl                                               \
      --disable-gtk                                               \
      --enable-2nd-ccache                                         \
      --disable-vte                                               \
      --disable-opengl                                            \
      --disable-virglrenderer                                     \
      --disable-werror                                            \
      --target-list=x86_64-linux-user                             \
      --enable-capstone=git                                       \
      --symcc-source=/symcc                                       \
      --symcc-build=/symcc/build && make -j
RUN cp /symelastic/build/x86_64-linux-user/symqemu-x86_64 /usr/bin/clb
RUN cd /symelastic && patch -R -p1 < /src/clb_config.patch
# build symsan for symelastic

RUN git clone https://github.com/enlighten5/symsan.git /symsan
RUN cd /symsan && git checkout symelastic && mkdir build && cd build
RUN CC=clang-12 CXX=clang++-12 cmake -DCMAKE_INSTALL_PREFIX=/symsan/build -DCMAKE_BUILD_TYPE=Release /symsan && make -j && make install

# build symelastic with mode switch and symsan (w/ solving and w/o solving)
RUN rm -rf /symelastic/build
RUN cd /symelastic && git checkout +symsan && mkdir build && cd build && ../configure     \
      --audio-drv-list=                                           \
      --disable-bluez                                             \
      --disable-sdl                                               \
      --disable-gtk                                               \
      --enable-2nd-ccache                                         \
      --disable-vte                                               \
      --disable-opengl                                            \
      --disable-virglrenderer                                     \
      --disable-werror                                            \
      --target-list=x86_64-linux-user                             \
      --enable-capstone=git                                       \
      --symsan-source=/symsan                                     \
      --symsan-build=/symsan/build                                \
      --symcc-source=/symcc_no_negate                             \
      --symcc-build=/symcc_no_negate/build && make -j
RUN cp /symelastic/build/x86_64-linux-user/symqemu-x86_64 /usr/bin/mode_switch_symsan

# build symelastic with mode switch + clb + symsan (w/ solving and w/o solving)
RUN rm -rf /symelastic/build
RUN cd /symelastic && git pull && git checkout clb+symsan && mkdir build && cd build && ../configure     \
      --audio-drv-list=                                           \
      --disable-bluez                                             \
      --disable-sdl                                               \
      --disable-gtk                                               \
      --enable-2nd-ccache                                         \
      --disable-vte                                               \
      --disable-opengl                                            \
      --disable-virglrenderer                                     \
      --disable-werror                                            \
      --target-list=x86_64-linux-user                             \
      --enable-capstone=git                                       \
      --symsan-source=/symsan                                     \
      --symsan-build=/symsan/build                                \
      --symcc-source=/symcc_no_negate                             \
      --symcc-build=/symcc_no_negate/build && make -j
RUN cp /symelastic/build/x86_64-linux-user/symqemu-x86_64 /usr/bin/clb_symsan

# build kirenenko
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- --default-toolchain=1.61.0 -y
ENV PATH="/root/.cargo/bin:${PATH}"
# RUN apt-get -y install libc++-dev libc++abi-dev
RUN git clone https://github.com/enlighten5/fastgen.git /fastgen
RUN cd /fastgen && \
    unset CFLAGS && \
    unset CXXFLAGS && \
    ./build/build.sh

COPY run_native.sh /src/cgc_programs/build/
COPY run_symsan.sh /src/cgc_programs/build_symsannosolve/
COPY run_symsan.sh /src/cgc_programs/build_symsan/
COPY run_symcc.sh /src/cgc_programs/build_symcc/
COPY run_symqemu.sh /src/cgc_programs/build/
COPY cgc_list /src/
COPY run_symsan_time.sh /src/build-programs-symsannosolve/
COPY run_symcc_time.sh /src/build-programs-symcc/
COPY run_symqemu_time.sh /src/build-programs-native/
COPY run_native_time.sh /src/build-programs-native/
COPY run_fuzzbench.sh /src/build-programs-native/
COPY run_fuzzbench_concrete.sh /src/build-programs-native/
COPY run_fuzzbench_nosolving.sh /src/build-programs-native/
COPY fuzzbench_time.sh /src/build-programs-native/
COPY run_oneseed.sh /src/build-programs-native/
#mem
COPY run_symcc_mem.sh /src/build-programs-symcc/
COPY run_native_mem.sh /src/build-programs-native/
COPY run_symsan_mem.sh /src/build-programs-symsannosolve/
RUN apt-get install -y time
COPY symcc_nosolve.patch /src
COPY symsan_cov.patch /src
COPY fuzzer.sh /src/build-programs-native/
