# [Choice] Python version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.10, 3.9, 3.8, 3.7, 3.6, 3-bullseye, 3.10-bullseye, 3.9-bullseye, 3.8-bullseye, 3.7-bullseye, 3.6-bullseye, 3-buster, 3.10-buster, 3.9-buster, 3.8-buster, 3.7-buster, 3.6-buster
ARG VARIANT="3.10-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/python:0-${VARIANT}

RUN pip3 --disable-pip-version-check --no-cache-dir install \
   awsume      \
   blastradius \
   boto3

USER vscode
RUN awsume-configure --shell=bash --alias-file="${HOME}/.bashrc"
RUN awsume-configure --shell=zsh --alias-file="${HOME}/.zshrc"
USER root
