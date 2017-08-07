#!/bin/bash
set -e
os_environment="$(cat /etc/issue | head -n1 | awk '{print $1;}')"

if [ "${os_environment}" == "\S" ]; then
    os_environment="Centos"
fi

echo "OS Environment: $os_environment"

if [ "${os_environment}" == "Ubuntu" ]; then

    apt-get update && apt-get --yes upgrade && apt-get --yes install aptitude apt-utils sudo locales && \
    apt-get clean all && rm -rf /var/lib/apt/lists/*
    # Locale
    sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

elif [ "${os_environment}" == "Centos" ]; then

    yum update -y &&  yum install -y epel-release deltarpm dnf && yum clean all && rm -rf /var/lib/apt/lists/*y 
    dnf -y update && dnf install -y dnf-plugins-core copr-cli
    
    # The Basics
    yum -y update && yum -y upgrade && yum -y install yum-utils sudo && \
    yum clean all && rm -rf /var/lib/apt/lists/*

    #Locale
    localedef -i en_GB -f UTF-8 en_GB.UTF-8
else 
    echo "Unknown"
fi

useradd -m --shell /bin/bash --uid $DATASCI_UID --user-group $DATASCI_USER 

mkdir -p $CONDA_DIR && chown $DATASCI_USER $CONDA_DIR

# Change ownership
chown -R $DATASCI_USER:$DATASCI_USER $CONDA_DIR

# Users passwords
echo "$DATASCI_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
echo "root:$DATASCI_USER" | chpasswd &&
mkdir -p $CONDA_SRC && chown -R $DATASCI_USER:$DATASCI_USER $CONDA_SRC
mkdir -p $Documents && chown -R $DATASCI_USER:$DATASCI_USER $Documents
mkdir -p $Downloads && chown -R $DATASCI_USER:$DATASCI_USER $Downloads
mkdir -p $Workspace && chown -R $DATASCI_USER:$DATASCI_USER $Workspace


if [ "${os_environment}" == "Ubuntu" ]; then
    apt-get update && apt-get install -yq --no-install-recommends \
    wget \
    curl \
    bzip2 \
    unzip \
    ca-certificates \
    fonts-liberation \
    software-properties-common \
    python-software-properties \
    libmagic-dev libghc-cairo-prof libcairo2-dev glib-2.0-dev libtinfo-dev \
    libunwind-dev libicu-dev libzmq5-dev libpango1.0-dev libblas-dev \
    liblapack-dev texlive texlive-latex-base texlive-latex-extra texlive-fonts-extra \
    texlive-fonts-recommended texlive-generic-recommended pandoc libghc-pandoc-dev \
    libboost-all-dev \
    git subversion mercurial && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

    # Install Java
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository --yes ppa:webupd8team/java && \
    apt-get update && \
    apt-get install --yes  oracle-java8-installer && \
    apt-get install --yes oracle-java8-set-default && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer

    apt-get update && apt-get --yes build-dep octave && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

elif [ "${os_environment}" == "Centos" ]; then

    yum -y update && yum install -y \
    wget \
    bzip2 \
    unzip \
    ca-certificates \
    fonts-liberation \
    file-devel ghc-cairo-devel cairo-devel glib2-devel \
    libicu-devel zeromq-devel pango-devel blas-devel \
    lapack-devel texlive ttexlive-latex texlive-xetex texlive-collection-latex \
    texlive-collection-latexrecommended texlive-xetex-def texlive-collection-xetex pandoc ghc-pandoc-devel \
    boost-devel \
    git subversion mercurial && \
    yum clean all && \
    rm -rf /var/lib/apt/lists/*

    # Install Java
    cd /tmp/ && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JDK_VERSION-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-$JDK_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm; yum -y install /tmp/jdk-8-linux-x64.rpm

    alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1
    alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 1

    dnf -y update && dnf copr enable nalimilan/julia -y

    yum -y update && yum-builddep -y octave && \
    yum clean all && \
    rm -rf /var/lib/apt/lists/*

else 
    echo "Unknown"
fi

cd /opt && git clone https://github.com/gibiansky/IHaskell && git clone --depth 1 https://github.com/minrk/clingkernel.git \
&& chown -R $DATASCI_USER:$DATASCI_USER $IHaskell && chown -R $DATASCI_USER:$DATASCI_USER $Cling

curl -sSL https://get.haskellstack.org/ | sh

cd /tmp && wget https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz && tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz
# TODO Fix Checksum

mkdir -p $TINI_DIR
cd $TINI_DIR
wget --quiet https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini
wget --quiet https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $TINI_CHECKSUM
gpg --verify $TINI_DIR/tini.asc
chmod +x $TINI_DIR/tini
chown -R $DATASCI_USER:$DATASCI_USER $TINI_DIR
cp $TINI_DIR/tini /usr/bin/tini