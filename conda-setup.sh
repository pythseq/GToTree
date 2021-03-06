#!/usr/bin/env bash

# setting colors to use
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

## checking that user conda version is at least 4.5.10 to avoid problems

cur_conda_version=$(conda --version 2>&1 | cut -f2 -d ' ')
too_old_version=4.5.0

if [ "$(printf '%s\n' "$cur_conda_version" "$too_old_version" | sort -V | head -n1)" != "$too_old_version" ]; then
    printf "\n    ${RED}It seems your conda version ($cur_conda_version) needs to be updated :(${NC}\n\n"
    printf "    Please update it with \`conda update conda\` and then try again.\n\n\n"
    printf "Exiting for now.\n\n"
    return
fi

printf "\n    ${GREEN}Setting up conda environment...${NC}\n\n"

## adding conda channels
conda config --add channels defaults 2> /dev/null
conda config --add channels bioconda 2> /dev/null
conda config --add channels conda-forge 2> /dev/null
conda config --add channels au-eoed 2> /dev/null

## creating GToTree environment and installing dependencies
conda create -n gtotree biopython hmmer=3.2.1 muscle=3.8.1551 trimal=1.4.1 fasttree=2.1.10 iqtree=1.6.9 prodigal=2.6.3 taxonkit=0.3.0 gnu-parallel=20161122 --yes

## activating environment
source activate gtotree 2> /dev/null || conda activate gtotree

## creating directory for conda-env-specific source files
mkdir -p ${CONDA_PREFIX}/etc/conda/activate.d

## adding GToTree bin path and GToTree_HMM_dir variable:
echo '#!/bin/sh'" \


export PATH=\"$(pwd)/bin:"'$PATH'\"" \

export GToTree_HMM_dir=\"$(pwd)/hmm_sets\"" >> ${CONDA_PREFIX}/etc/conda/activate.d/env_vars.sh

printf "    ${GREEN}Setting up TaxonKit for adding lineage info to trees...${NC}\n\n"

## downloading ncbi tax database for taxonkit and setting variable for location
mkdir -p ncbi_tax_info
cd ncbi_tax_info

curl --silent --retry 10 -O ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

tar -xzf taxdump.tar.gz
rm taxdump.tar.gz

echo "export TAXONKIT_DB=$(pwd)" >> ${CONDA_PREFIX}/etc/conda/activate.d/env_vars.sh

cd ../

## adding variables to the conda environment so localization matches what the program expects
echo 'export LC_ALL="en_US.UTF-8"' >> ${CONDA_PREFIX}/etc/conda/activate.d/env_vars.sh
echo 'export LANG="en_US.UTF-8"' >> ${CONDA_PREFIX}/etc/conda/activate.d/env_vars.sh

# re-activating environment so variable and PATH changes take effect
source activate gtotree 2> /dev/null || conda activate gtotree

## removing citation notifications from `parallel` (i note on all places it is mentioned to please cite them and all tools in here)
printf "will cite" | parallel --citation 2&> /dev/null

printf "\n        ${GREEN}DONE!${NC}\n\n"
