# development machine
#
FROM ubuntu:17.10

# Start by changing the apt output, as stolen from Discourse's Dockerfiles.
RUN echo "debconf debconf/frontend select Teletype" | debconf-set-selections

RUN apt-get update && apt-get install -y software-properties-common ca-certificates
RUN add-apt-repository ppa:martin-frost/thoughtbot-rcm
RUN add-apt-repository ppa:neovim-ppa/unstable

# common packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
      build-essential \
      gcc-6 \
      locales \
      curl \
      git  \
      iputils-ping \
      libncurses5-dev \
      libevent-dev \
      net-tools \
      netcat-openbsd \
      silversearcher-ag \
      socat \
      tzdata \
      wget \
      zsh \
      rcm \
      neovim \
      python3-neovim \
      ctags \
      openssh-client \
      direnv \
      mosh \
      sudo \
      whois \
      dnsutils \
      traceroute \
      apt-transport-https

# stuff usually needed for ruby dev
RUN apt-get install -y \
  zlib1g-dev \
  libssl-dev \
  libreadline-dev \
  libyaml-dev \
  libxml2-dev \
  libxslt-dev \
  libffi-dev \
  libsqlite3-dev \
  libpq-dev

# install tmux
ENV tmux_version 2.6
WORKDIR /usr/local/src
RUN wget https://github.com/tmux/tmux/releases/download/${tmux_version}/tmux-${tmux_version}.tar.gz
RUN tar xzvf tmux-${tmux_version}.tar.gz
WORKDIR /usr/local/src/tmux-${tmux_version}
RUN ./configure
RUN make 
RUN make install
RUN rm -rf /usr/local/src/tmux*

# use nvim instead of vim
RUN ln -s /usr/bin/nvim /usr/local/bin/vim

# install ssh
RUN apt-get install -y openssh-server &&\
    mkdir /var/run/sshd &&\
    echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config

# prepare locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "sv_SE.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen --purge --lang en_US \
    && locale-gen --purge --lang sv_SE \
    && locale-gen
ENV LANG en_US.utf8

# setup heroku-cli
RUN echo "deb https://cli-assets.heroku.com/branches/stable/apt ./" > /etc/apt/sources.list.d/heroku.list
RUN wget -qO- https://cli-assets.heroku.com/apt/release.key | apt-key add -
RUN apt-get update && apt-get install -y heroku

# setup user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID dev
RUN useradd dev -u $UID -g $GID -d /home/dev -m -s /bin/zsh &&\
    adduser dev sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER dev

# setup rbenv
RUN git clone https://github.com/rbenv/rbenv.git /home/dev/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git /home/dev/.rbenv/plugins/ruby-build
ENV PATH /home/dev/.rbenv/bin:$PATH
RUN CC=/usr/bin/gcc-6 rbenv install 2.3.3
RUN CC=/usr/bin/gcc-6 rbenv install 2.3.4
RUN CC=/usr/bin/gcc-6 rbenv install 2.4.2
RUN CC=/usr/bin/gcc-6 rbenv install 2.5.0
RUN CC=/usr/bin/gcc-6 rbenv global 2.5.0

# clone dotfiles
RUN git clone https://github.com/ksoderstrom/dotfiles.git /home/dev/.dotfiles
RUN git -C /home/dev/.dotfiles remote set-url origin git@github.com:ksoderstrom/dotfiles.git
RUN rcup

# install n
RUN curl -L https://git.io/n-install | bash -s -- -y

# install zim
RUN git clone --recursive https://github.com/Eriner/zim.git /home/dev/.zim

# install vim plugins
RUN curl -fLo /home/dev/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && vim +PlugInstall +UpdateRemotePlugins +qall

# tmux plugin manager
RUN git clone https://github.com/tmux-plugins/tpm /home/dev/.tmux/plugins/tpm
RUN /home/dev/.tmux/plugins/tpm/bin/install_plugins

EXPOSE 22

RUN mkdir /home/dev/code
VOLUME /home/dev/code

CMD sudo /usr/sbin/sshd -D
