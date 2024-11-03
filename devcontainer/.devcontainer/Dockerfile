FROM mcr.microsoft.com/devcontainers/typescript-node:latest

LABEL org.opencontainers.image.source=https://github.com/fabian-lohauss/CloudDeploymentFramework
LABEL org.opencontainers.image.description="CloudDeploymentFramework DevContainer image"
LABEL org.opencontainers.image.licenses=MIT

# Update package lists, upgrade installed packages, and clean up in a single RUN command
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*