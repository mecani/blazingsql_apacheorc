FROM nvidia/cudagl:10.2-base-ubuntu18.04
MAINTAINER Manuel Bergeron <manuelbergeron@hotmail.com>
RUN pwd
RUN ln -fs /usr/share/zoneinfo/America/Montreal /etc/localtime
RUN apt-get update
RUN apt-get install -y \
  cmake \
  gcc \
  g++ \
  git \
  libsasl2-dev \
  libssl-dev \
  make \
  maven \
  openjdk-8-jdk \
  openjdk-8-jre \
  tzdata
RUN update-java-alternatives --jre-headless --jre --set java-1.8.0-openjdk-amd64
WORKDIR /root
VOLUME /root/.m2/repository
RUN git clone https://github.com/apache/orc.git -b master
RUN mkdir build && cd build && cmake ../orc

WORKDIR /root/build
RUN make package test-out VERBOSE=1
RUN tar xzf ./ORC-*-SNAPSHOT-Linux.tar.gz -C /tmp
RUN cp -rf /tmp/ORC-*-SNAPSHOT-Linux /opt/orc
RUN cp ./tools/src/csv-import /opt/orc/bin
RUN cp ./tools/src/timezone-dump /opt/orc/bin

WORKDIR /opt/orc
RUN for i in /opt/orc/share/*.jar; do file="${i##*/}"; echo '#!/bin/bash\nexec java -jar' "$i" \"\$@\" > /opt/orc/bin/"${file%%-[[:digit:]]*}"; done
RUN chmod -R +x /opt/orc/bin/*
ENV PATH="/opt/orc/bin:${PATH}"

# installing conda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

WORKDIR /
# create conda environment
COPY environment.yml .
COPY requirements.txt .
RUN conda update -n base -c defaults conda
RUN conda env create -f environment.yml python=3.8

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "blazingsql", "/bin/bash", "-c"]

RUN mkdir /blazingsql
RUN mkdir /blazingsql/project
VOLUME /blazingsql/project

COPY entrypoint.sh .
RUN chmod +x /entrypoint.sh
WORKDIR /blazingsql
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
