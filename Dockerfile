############################################################
# Dockerfile file to build the vhsbot container
# AUTHOR: Sean Patrick Hagen <sean.hagen@gmail.com>
# Version 0.1
############################################################

# Pull base image.
FROM guttertec/nodejs
MAINTAINER Sean Patrick Hagen <sean.hagen@gmail.com>

# Install CoffeeScript, Hubot
RUN \
  apt-get update && \
  apt-get install -y redis-server && \
  rm -rf /var/lib/apt/lists/*

# Define default command.
EXPOSE 6379
RUN /etc/init.d/redis-server start

# Create Hubot
WORKDIR /root
RUN hubot --create mybot
WORKDIR /root/mybot
RUN npm install
