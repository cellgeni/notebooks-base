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
    libxml2-dev \
    libapparmor1 \
    libedit2 \
    libhdf5-dev \
    lsb-release \
    psmisc \
    rsync \
    vim \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'install.packages(c("tidyR", "Seurat", "vcfR", "rJava", "gProfileR"))' > /opt/packages1.r && Rscript /opt/packages1.r

USER $NB_UID
