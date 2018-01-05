FROM ubuntu:17.10

# Use bash
RUN rm /bin/sh && ln -sf /bin/bash /bin/sh

# Install Prereqs
RUN apt-get update && \
  apt-get install \
  # Installation deps and tools
  apt-transport-https ca-certificates curl software-properties-common \
  build-essential \
  # Dev tools
  vim git zsh -y && \
  # Docker
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
  apt-get update && apt-get install docker-ce -y && \
  # Node (C9 needs v6)
  curl --silent --location https://deb.nodesource.com/setup_6.x | bash - && \
  apt-get install nodejs -y

# Install C9
RUN git clone git://github.com/c9/core.git /c9 && \
  /c9/scripts/install-sdk.sh

# Create workspace
RUN mkdir /workspace

# Start C9
CMD node /c9/server.js -p $C9PORT -a $C9USER:$C9PASS --listen 0.0.0.0 -w /workspace