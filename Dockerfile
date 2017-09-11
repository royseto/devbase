# Build a dev tools image with Python, R, NodeJS, PhantomJS, and
# various editors and utilities.
#
# This exposes an SSH service.

FROM royseto/pgbuild:next

ENV DEBIAN_FRONTEND noninteractive

# Set locale to US. Override in derivative image if needed.

RUN apt-get update && apt-get install -y language-pack-en
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Add package repositories.

RUN apt-get install -y -q software-properties-common && \
    add-apt-repository 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/' && \
    add-apt-repository ppa:git-core/ppa && \
    add-apt-repository ppa:pi-rho/dev && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    apt-get update && apt-get install -y -q curl && \
    (curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -)

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
    r-base \
    r-base-dev \
    silversearcher-ag \
    tmux \
    unzip \
    vim \
    wget \
    zip \
    zsh

# Install RVM, Ruby, and gist.

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    (curl -sSL https://get.rvm.io | bash -s stable --ruby) && \
    bash -c "(. /usr/local/rvm/scripts/rvm && gem install gist)"

# Install npm packages.

RUN npm install -g brunch@2.10.9 && \
    npm install -g karma-cli@1.0.1 && \
    npm install -g bower@1.8.0 && \
    npm install -g tern js-beautify jshint

# Install csvkit.

RUN pip install csvkit

# Install R packages.

COPY install_packages.R /tmp/build/
WORKDIR /tmp/build
RUN R CMD BATCH --no-save --no-restore install_packages.R

# Install PhantomJS.

COPY install_phantomjs.sh /tmp/build/
RUN /tmp/build/install_phantomjs.sh

# Install GNU Parallel.

RUN (wget -O - pi.dk/3 || curl pi.dk/3/ || fetch -o - http://pi.dk/3) | bash
RUN bash -c "(echo 'will cite' | parallel --bibtex)"

# Install Redis.

COPY install_redis.sh /tmp/build/
RUN /tmp/build/install_redis.sh

# Install Emacs 24.5 from private Debian package
# to work around https://github.com/docker/docker/issues/22801

# RUN wget http://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.gz && tar xzf emacs-24.5.tar.gz
# WORKDIR /tmp/build/emacs-24.5
# RUN ./configure && make && make install

RUN wget https://s3-us-west-1.amazonaws.com/royseto-public/dpkg/emacs24.5.2_24.5.2-1_amd64.deb \
  && dpkg -i /tmp/build/emacs24.5.2_24.5.2-1_amd64.deb

# Install Python 2.7.11.

RUN apt-get update -y && apt-get install -y libffi-dev libffi6 libffi6-dbg && \
    wget https://s3-us-west-1.amazonaws.com/royseto-public/dpkg/python2.7.11_2.7.11-local1_amd64.deb && \
    dpkg -i python2.7.11_2.7.11-local1_amd64.deb

# Install PyPy.

COPY install_pypy.sh /tmp/build/
RUN chmod 755 /tmp/build/install_pypy.sh && /tmp/build/install_pypy.sh

# Enable passwordless sudo for users in the sudo group.

RUN sed -ie '/sudo/ s/ALL$/NOPASSWD: ALL/' /etc/sudoers

# Clean up.

WORKDIR /
RUN /bin/rm -rf /tmp/build
