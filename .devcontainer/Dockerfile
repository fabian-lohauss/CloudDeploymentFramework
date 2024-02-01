FROM mcr.microsoft.com/devcontainers/typescript-node

# install powershell
RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    software-properties-common

RUN wget -q "https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb" \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y powershell

LABEL org.opencontainers.image.source=https://github.com/fabian-lohauss/DeploymentFramework
LABEL org.opencontainers.image.description="DeploymentFramework DevContainer image"
LABEL org.opencontainers.image.licenses=MIT