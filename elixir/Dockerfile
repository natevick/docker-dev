ARG ELIXIR_VERSION

FROM elixir:$ELIXIR_VERSION

ARG DEBIAN_FRONTEND=noninteractive

###############################################################################
# Base Software Install
###############################################################################

ARG NODE_VERSION=16

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
ARG USER=elixir
ENV USER $USER

RUN groupadd -g $GID $USER && \
    useradd -u $UID -g $USER -m $USER && \
    usermod -p "*" $USER && \
    usermod -aG sudo $USER && \
    echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers.d/50-$USER

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

RUN mkdir -p /app && chown $USER:$USER /app

# Init persistent .zsh_history
ENV HISTFILE=/history/.zsh_history
RUN mkdir -p /history && chown $USER:$USER /history

# Switch back to default user (elixir)
USER $USER

# Set default shell to ZSH
ENV SHELL=/bin/zsh

# Install fzf from source
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
  ~/.fzf/install

# Install oh-my-zsh
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

WORKDIR /app