# Build a dev tools image with Python, NodeJS, PhantomJS, and
# various editors and utilities.
#
# This exposes an SSH service.

FROM royseto/pgbuild

ENV DEBIAN_FRONTEND noninteractive

# Set locale to US. Override in derivative image if needed.

RUN apt-get update && apt-get install -y language-pack-en
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Add package repositories.

RUN apt-get install -y -q software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    add-apt-repository -y ppa:pi-rho/dev && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    apt-get update && apt-get install -y -q curl && \
    (curl -sL https://deb.nodesource.com/setup_10.x | bash -)

# Install Ubuntu packages.

RUN apt-get update && apt-get install -y -q \
    build-essential \
    bzip2 \
    curl \
    git \
    git-man \
    keychain \
    nodejs \
    openssh-client \
    openssh-server \
    python-dev \
    python-pip \
    python-software-properties \
    python-virtualenv \
    python2.7 \
    python2.7-dev \
    silversearcher-ag \
    sudo \
    tmux \
    unzip \
    vim \
    wget \
    zip \
    zsh

# Install RVM, Ruby, and gist.

RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    (curl -sSL https://get.rvm.io | bash -s stable --ruby) && \
    bash -c "(. /usr/local/rvm/scripts/rvm && gem install gist)"

# Install npm packages.

RUN npm install -g brunch@2.10.9 && \
    npm install -g karma-cli@1.0.1 && \
    npm install -g bower@1.8.0 && \
    npm install -g tern js-beautify jshint prettier

# Install csvkit.

RUN pip install csvkit

# Install PhantomJS.

COPY install_phantomjs.sh /tmp/build/
RUN /tmp/build/install_phantomjs.sh

# Install GNU Parallel.

RUN (wget -O - pi.dk/3 || curl pi.dk/3/ || fetch -o - http://pi.dk/3) | bash
RUN bash -c "(echo 'will cite' | parallel --bibtex)" || true

# Install Redis.

COPY install_redis.sh /tmp/build/
RUN /tmp/build/install_redis.sh

# Install Emacs 26.1 from private Debian package
# to work around https://github.com/docker/docker/issues/22801

# RUN wget http://ftp.gnu.org/gnu/emacs/emacs-26.1.tar.gz && tar xzf emacs-26.1.tar.gz
# WORKDIR /tmp/build/emacs-26.1
# RUN ./configure --with-gnutls=no && make && make install
#
# To build private Debian package:
# See https://github.com/jordansissel/fpm/wiki/PackageMakeInstall
#
# Install Ruby and FPM
# make install DESTDIR=/tmp/installdir
# fpm -s dir -t deb -C /tmp/installdir -n emacs26.1 -v 26.1-1 \
#     -p emacs26.1_VERSION_ARCH.deb --description 'Emacs 26.1' usr

WORKDIR /tmp/build

RUN wget -q https://s3-us-west-1.amazonaws.com/royseto-public/dpkg/emacs26.1_26.1-1_amd64.deb \
  && dpkg -i /tmp/build/emacs26.1_26.1-1_amd64.deb

# Install Python 2.7.11.

RUN apt-get update -y && apt-get install -y libffi-dev libffi6 libffi6-dbg && \
    wget -q https://s3-us-west-1.amazonaws.com/royseto-public/dpkg/python2.7.11_2.7.11-local1_amd64.deb && \
    dpkg -i python2.7.11_2.7.11-local1_amd64.deb

# Install PyPy.

COPY install_pypy.sh /tmp/build/
RUN bash /tmp/build/install_pypy.sh

# Enable passwordless sudo for users in the sudo group.

RUN sed -ie '/sudo/ s/ALL$/NOPASSWD: ALL/' /etc/sudoers

# Clean up.

WORKDIR /
RUN /bin/rm -rf /tmp/build
