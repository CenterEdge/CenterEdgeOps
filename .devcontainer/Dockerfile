# [Choice] Python version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.10, 3.9, 3.8, 3.7, 3.6, 3-bullseye, 3.10-bullseye, 3.9-bullseye, 3.8-bullseye, 3.7-bullseye, 3.6-bullseye, 3-buster, 3.10-buster, 3.9-buster, 3.8-buster, 3.7-buster, 3.6-buster
ARG VARIANT="3.10-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/python:0-${VARIANT}

ENV DCTLENV_VER=v0.1.9   \
    DRIFTCTL_VER=0.38.2

RUN apt-get update && apt-get install -y \
    wget   \
    unzip  \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 --disable-pip-version-check --no-cache-dir install \
  awsume      \
  blastradius \
  boto3

# Install InfraCost
RUN curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
USER vscode

# Install driftctl (via dctlenv for multiarch logic)
RUN export PATH="$HOME/.dctlenv/bin:$PATH" \
  && git clone --depth 1 --branch ${DCTLENV_VER} https://github.com/wbeuil/dctlenv ${HOME}/.dctlenv \
  && dctlenv install ${DRIFTCTL_VER} \
  && dctlenv use ${DRIFTCTL_VER} \
  && echo "export PATH=${HOME}/.dctlenv/bin:$PATH" >> ${HOME}/.bashrc

# Install InfraCost
RUN curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

RUN awsume-configure
RUN awsume-configure --shell=bash --alias-file="${HOME}/.bashrc"
RUN awsume-configure --shell=zsh --alias-file="${HOME}/.zshrc"
# USER root

