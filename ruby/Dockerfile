ARG ruby_version

FROM ruby:$ruby_version

ARG DEBIAN_FRONTEND=noninteractive

###############################################################################
# Base Software Install
###############################################################################

ARG NODE_VERSION=12

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Add source for RCM
RUN wget https://thoughtbot.com/thoughtbot.asc && \
  apt-key add - < thoughtbot.asc && \
  echo "deb https://apt.thoughtbot.com/debian/ stable main" | tee /etc/apt/sources.list.d/thoughtbot.list

RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    yarn \
    locales \
    git \
    netcat \
    vim \
    sudo \
    zsh \
    rcm \
    less

###############################################################################
# Non-root user
###############################################################################

# TODO remove UID GID defaults
ARG UID=1000
ENV UID $UID
ARG GID=1000
ENV GID $GID
ARG USER=ruby
ENV USER $USER

RUN groupadd -g $GID $USER && \
    useradd -u $UID -g $USER -m $USER && \
    usermod -p "*" $USER && \
    usermod -aG sudo $USER && \
    echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers.d/50-$USER

###############################################################################
# Ruby, Rubygems, and Bundler Defaults
###############################################################################

ENV LANG C.UTF-8

# Point Bundler at /gems. This will cause Bundler to re-use gems that have already been installed on the gems volume
ENV BUNDLE_PATH /gems
ENV BUNDLE_HOME /gems

# Increase how many threads Bundler uses when installing. Optional!
ARG BUNDLE_JOBS=20
ENV BUNDLE_JOBS $BUNDLE_JOBS

# How many times Bundler will retry a gem download. Optional!
ARG BUNDLE_RETRY=5
ENV BUNDLE_RETRY $BUNDLE_RETRY

# Where Rubygems will look for gems, similar to BUNDLE_ equivalents.
ENV GEM_HOME /gems
ENV GEM_PATH /gems

# Add /gems/bin to the path so any installed gem binaries are runnable from bash.
ENV PATH /gems/bin:$PATH

###############################################################################
# Optional Software Install
###############################################################################


###############################################################################
# Final Touches
###############################################################################

# Set locale (tmux crashes otherwise)
RUN echo "LC_ALL=en_US.UTF-8" | tee /etc/environment && \
  echo "en_US.UTF-8 UTF-8" | tee /etc/locale.gen && \
  echo "LANG=en_US.UTF-8" | tee /etc/locale.conf && \
  locale-gen en_US.UTF-8

# Build tmux from source
RUN TMUX_VERSION=2.9a && \
  wget https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz && \
  tar xf tmux-$TMUX_VERSION.tar.gz && \
  rm -f tmux-$TMUX_VERSION.tar.gz && \
  cd tmux-$TMUX_VERSION && \
  ./configure && \
  make && \
  sudo make install && \
  cd - && \
  sudo rm -rf /usr/local/src/tmux-\* && \
  sudo mv tmux-$TMUX_VERSION /usr/local/src

RUN mkdir -p "$GEM_HOME" && chown $USER:$USER "$GEM_HOME"
RUN mkdir -p /app && chown $USER:$USER /app

# Init persistent .zsh_history
ENV HISTFILE=/history/.zsh_history
RUN mkdir -p /history && chown $USER:$USER /history

# Install latest bundler
RUN gem install bundler --default

# Switch back to default user (ruby)
USER $USER

# Set default shell to ZSH
ENV SHELL=/bin/zsh

# Install fzf from source
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
  ~/.fzf/install

# Install oh-my-zsh
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

WORKDIR /app