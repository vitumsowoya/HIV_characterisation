conda install -c bioconda fastqc
conda install -c bioconda trimmomatic

#create a new environment when installing iva because dependencies crash with fastqc and trimmomatic
conda create -n iva_env
conda install -c bioconda iva

#make sure to always check version of installed tools and document by writing "-version" at the end of tool name i.e
fastqc -version
