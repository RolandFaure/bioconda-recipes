#!/bin/bash

set -xe

mkdir -p $PREFIX/bin
export CXXFLAGS="${CXXFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
  export CXXFLAGS="${CXXFLAGS} -std=libc++"
else
  export CONFIG_ARGS=""
fi

mkdir src/build
cd src/build/
cmake -S .. -B . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  "${CONFIG_ARGS}"
cmake --build . -j "${CPU_COUNT}"

install -v -m 0755 HS_GenomeTailor/HS_GenomeTailor $PREFIX/bin
install -v -m 0755 HS_call_variants HS_create_new_contigs HS_fa2gfa HS_gfa2fa HS_separate_reads ${PREFIX}/bin
install -v -m 0755 ../cut_gfa.py ${PREFIX}/bin
install -v -m 0755 ../GraphUnzip/*.py ${PREFIX}/bin
install -v -m 0755 ../../hairsplitter.py ${PREFIX}/bin
