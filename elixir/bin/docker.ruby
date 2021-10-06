#!/bin/zsh
source ~/.zshrc
docker-compose -p ruby-dev-${RUBY_VERSION:-"2.6"} -f ~/repos/personal/docker-dev/ruby/docker-compose.yml --project-directory . run --rm app "$@"
