# Distributed under the terms of the Modified BSD License.
FROM jupyter/scipy-notebook

USER root

# pre-requisites
RUN apt-get update && apt-get install -yq --no-install-recommends \
    python3-software-properties \
    software-properties-common \
    apt-utils \
    gnupg2 \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc \
    clang-6.0 \
    openssh-client \
    openssh-server \
    cmake \
    python-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2 \
    libxml2-dev \
    libapparmor1 \
    libedit2 \
    libhdf5-dev \
    lsb-release \
    psmisc \
    rsync \
    vim \
    default-jdk \
    libbz2-dev \
    libpcre3-dev \
    liblzma-dev \
    zlib1g-dev \
    xz-utils \
    liblapack-dev \
    libopenblas-dev \
    libigraph0-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install scanpy
RUN pip install scanpy python-igraph louvain
RUN pip install --editable=git+https://github.com/DmitryUlyanov/Multicore-TSNE.git#egg=MulticoreTSNE

# RStudio
ENV RSTUDIO_PKG=rstudio-server-1.1.456-amd64.deb
RUN wget -q http://download2.rstudio.org/${RSTUDIO_PKG}
RUN dpkg -i ${RSTUDIO_PKG}
RUN rm ${RSTUDIO_PKG}
# The desktop package uses /usr/lib/rstudio/bin
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/opt/conda/lib/R/lib"

# nbrsessionproxy extension
RUN pip install git+https://github.com/jupyterhub/nbrsessionproxy.git
RUN jupyter serverextension enable --sys-prefix --py nbrsessionproxy
RUN jupyter nbextension install    --sys-prefix --py nbrsessionproxy
RUN jupyter nbextension enable --sys-prefix --py nbrsessionproxy

# R packages
# https://askubuntu.com/questions/610449/w-gpg-error-the-following-signatures-couldnt-be-verified-because-the-public-k
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
# https://cran.r-project.org/bin/linux/ubuntu/README.html
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" | sudo tee -a /etc/apt/sources.list
# https://launchpad.net/~marutter/+archive/ubuntu/c2d4u3.5
RUN add-apt-repository ppa:marutter/c2d4u3.5
# Install CRAN binaries from ubuntu
RUN apt-get update && apt-get install -yq --no-install-recommends \
    r-base \
    r-cran-devtools \
    r-cran-tidyverse \
    r-cran-pheatmap \
    r-cran-plyr \
    r-cran-dplyr \
    r-cran-readr \
    r-cran-reshape2 \
    r-cran-reticulate \
    r-cran-viridis \
    r-cran-ggplot2 \
    r-cran-ggthemes \
    r-cran-cowplot \
    r-cran-ggforce \
    r-cran-ggridges \
    r-cran-ggrepel \
    r-cran-gplots \
    r-cran-igraph \
    r-cran-car \
    r-cran-ggpubr \
    r-cran-httpuv \
    r-cran-xtable \
    r-cran-sourcetools \
    r-cran-modeltools \
    r-cran-R.oo \
    r-cran-R.methodsS3 \
    r-cran-shiny \
    r-cran-later \
    r-cran-checkmate \
    r-cran-bibtex \
    r-cran-lsei \
    r-cran-bit \
    r-cran-segmented \
    r-cran-mclust \
    r-cran-flexmix \
    r-cran-prabclus \
    r-cran-diptest \
    r-cran-mvtnorm \
    r-cran-robustbase \
    r-cran-kernlab \
    r-cran-trimcluster \
    r-cran-proxy \
    r-cran-R.utils \
    r-cran-htmlwidgets \
    r-cran-hexbin \
    r-cran-crosstalk \
    r-cran-promises \
    r-cran-acepack \
    r-cran-zoo \
    r-cran-npsurv \
    r-cran-iterators \
    r-cran-snow \
    r-cran-bit64 \
    r-cran-permute \
    r-cran-mixtools \
    r-cran-lars \
    r-cran-ica \
    r-cran-fpc \
    r-cran-ape \
    r-cran-pbapply \
    r-cran-irlba \
    r-cran-dtw \
    r-cran-plotly \
    r-cran-metap \
    r-cran-lmtest \
    r-cran-fitdistrplus \
    r-cran-png \
    r-cran-foreach \
    r-cran-vegan \
    r-cran-tidyr \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install hdf5r for Seurat
RUN Rscript -e 'install.packages("hdf5r",configure.args="--with-hdf5=/usr/bin/h5cc")'
# Install other CRAN
RUN Rscript -e 'install.packages(c("Seurat", "vcfR", "rJava", "gProfileR"))'

# Install Bioconductor packages
RUN echo 'source("https://bioconductor.org/biocLite.R")' > /opt/bioconductor.r && \
    echo 'biocLite()' >> /opt/bioconductor.r && \
    echo 'biocLite(c("pcaMethods", "limma", "SingleCellExperiment", "Rhdf5lib", "beachmat", "scater", "scran", "RUVSeq", "sva", "SC3", "TSCAN", "monocle", "destiny", "DESeq2", "edgeR", "MAST", "scfind", "scmap", "BiocParallel", "zinbwave", "GenomicAlignments", "RSAMtools", "M3Drop", "DropletUtils", "switchde", "biomaRt", "org.Hs.eg.db", "goseq"))' >> /opt/bioconductor.r && \
    Rscript /opt/bioconductor.r

USER $NB_UID
