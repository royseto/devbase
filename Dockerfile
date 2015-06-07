# Build a dev tools image with Python, R, NodeJS, PhantomJS, and
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
    add-apt-repository 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/' && \
    add-apt-repository ppa:git-core/ppa && \
    add-apt-repository ppa:pi-rho/dev && \
    add-apt-repository ppa:ubuntu-elisp/ppa && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update && apt-get install -y -q curl && \
    (curl -sL https://deb.nodesource.com/setup | bash -)

# Install Ubuntu packages.

RUN apt-get update && apt-get install -y -q \
    build-essential \
    bzip2 \
    curl \
    emacs-snapshot \
    git \
    git-man \
    imagemagick \
    keychain \
    nodejs \
    openssh-client \
    openssh-server \
    optipng \
    python-dev \
    python-pip \
    python-software-properties \
    python-virtualenv \
    python2.7 \
    python2.7-dev \
    r-base \
    r-base-dev \
    tmux \
    unzip \
    vim \
    wget \
    zip \
    zsh

# Install RVM, Ruby, and gist.

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    (curl -sSL https://get.rvm.io | bash -s stable --ruby) \
    bash -c "(. /usr/local/rvm/scripts/rvm && gem install gist)"

# Install npm packages.

RUN npm install -g brunch@1.8.3 karma@0.12.32 karma-cli@0.0.4 bower@1.4.1

# Install csvkit.

RUN pip install csvkit

# Install R packages.

COPY install_packages.R /tmp/build/
WORKDIR /tmp/build
RUN R CMD BATCH --no-save --no-restore install_packages.R

# Install PhantomJS.

install_phantomjs.sh /tmp/build/
RUN /tmp/build/install_phantomjs.sh

# Install GNU Parallel.

RUN (wget -O - pi.dk/3 || curl pi.dk/3/ || fetch -o - http://pi.dk/3) | bash
RUN bash -c "(echo 'will cite' | parallel --bibtex)"

# Install Redis.

COPY install_redis.sh /tmp/build/
RUN /tmp/build/install_redis.sh

# Enable passwordless sudo for users in the sudo group.

RUN sed -ie '/sudo/ s/ALL$/NOPASSWD: ALL/' /etc/sudoers

# Clean up.

WORKDIR /
RUN /bin/rm -rf /tmp/build

