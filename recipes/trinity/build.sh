#!/bin/bash -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -fopenmp"

export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include ${LDFLAGS}"

export BINARY_HOME="${PREFIX}/bin"
export TRINITY_HOME="${PREFIX}/opt/trinity-${PKG_VERSION}"

if [ "$(uname)" == "Darwin" ]; then
    # for Mac OSX
    export CXXFLAGS="${CXXFLAGS} -std=c++14"
fi

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j "${CPU_COUNT}" plugins
make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"

# remove the sample data
rm -rf ${SRC_DIR}/sample_data

# reproduce make install without the wrapper script
mkdir -p ${PREFIX}/bin
mkdir -p ${TRINITY_HOME}/Butterfly
chmod 0755 Trinity
cp -rf Trinity ${TRINITY_HOME}/
mv Analysis ${TRINITY_HOME}/
cp -rf Butterfly/Butterfly.jar ${TRINITY_HOME}/Butterfly
mkdir -p ${TRINITY_HOME}/Chrysalis
cp -LR Chrysalis/bin ${TRINITY_HOME}/Chrysalis
mkdir -p ${TRINITY_HOME}/Inchworm
cp -LR Inchworm/bin ${TRINITY_HOME}/Inchworm
cp -LR PerlLib ${TRINITY_HOME}/
cp -LR PyLib ${TRINITY_HOME}/
cp -LR trinity-plugins ${TRINITY_HOME}/
cp -LR util ${TRINITY_HOME}/

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${TRINITY_HOME}/util/*.pl
rm -rf ${TRINITY_HOME}/util/*.bak
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${TRINITY_HOME}/util/misc/*.pl
rm -rf ${TRINITY_HOME}/util/misc/*.bak
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${TRINITY_HOME}/util/support_scripts/*.pl
rm -rf ${TRINITY_HOME}/util/support_scripts/*.bak

# add link to Trinity from bin so in PATH
cd ${BINARY_HOME}
ln -sf ${TRINITY_HOME}/Trinity
ln -sf ${TRINITY_HOME}/util/*.pl .
ln -sf ${TRINITY_HOME}/Analysis/DifferentialExpression/PtR
ln -sf ${TRINITY_HOME}/Analysis/DifferentialExpression/run_DE_analysis.pl
ln -sf ${TRINITY_HOME}/Analysis/DifferentialExpression/analyze_diff_expr.pl
ln -sf ${TRINITY_HOME}/Analysis/DifferentialExpression/define_clusters_by_cutting_tree.pl
ln -sf ${TRINITY_HOME}/Analysis/SuperTranscripts/Trinity_gene_splice_modeler.py
ln -sf ${TRINITY_HOME}/Analysis/SuperTranscripts/extract_supertranscript_from_reference.py
ln -sf ${TRINITY_HOME}/util/support_scripts/get_Trinity_gene_to_trans_map.pl
ln -sf ${TRINITY_HOME}/util/misc/contig_ExN50_statistic.pl
cp -rf ${TRINITY_HOME}/trinity-plugins/BIN/seqtk-trinity .

# Find real path when executing from a symlink
export LC_ALL=C
find ${TRINITY_HOME} -type f -print0 | xargs -0 sed -i.bak 's/FindBin::Bin/FindBin::RealBin/g'

# Replace hard coded path to deps
find ${TRINITY_HOME} -type f -print0 | xargs -0 sed -i.bak 's/$JELLYFISH_DIR\/bin\/jellyfish/jellyfish/g'
sed -i.bak "s/\$ROOTDIR\/trinity-plugins\/Trimmomatic/\/opt\/anaconda1anaconda2anaconda3\/share\/trimmomatic/g" ${TRINITY_HOME}/Trinity
sed -i.bak 's/my $TRIMMOMATIC = "\([^"]\+\)"/my $TRIMMOMATIC = '"'"'\1'"'"'/' ${TRINITY_HOME}/Trinity
sed -i.bak 's/my $TRIMMOMATIC_DIR = "\([^"]\+\)"/my $TRIMMOMATIC_DIR = '"'"'\1'"'"'/' ${TRINITY_HOME}/Trinity

find ${TRINITY_HOME} -type f -name "*.bak" -print0 | xargs -0 rm -f

# export TRINITY_HOME as ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export TRINITY_HOME=${TRINITY_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset TRINITY_HOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
