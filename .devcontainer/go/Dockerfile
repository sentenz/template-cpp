ARG VARIANT=1.25-trixie@sha256:bf7af54b660d7fc58068213bea0da7ec65dbf6437d77ddff2bb52e3f530b6a10
FROM golang:${VARIANT}

# Fixing vulnerability issue by upgrading svn to 1.14.5. Ref https://subversion.apache.org/security/CVE-2024-46901-advisory.txt
COPY ./scripts/install-subversion.sh /tmp/install-subversion.sh
RUN chmod +x /tmp/install-subversion.sh
RUN /tmp/install-subversion.sh \
  && rm -f /tmp/install-subversion.sh

# [Optional] Uncomment the next line to use go get to install anything else you need
# RUN go get -x <your-dependency-or-tool>

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
