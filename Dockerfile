ARG TEXLIVE_DIR=/usr/local/texlive
ARG TEXLIVE_BINARIES=$TEXLIVE_DIR/bin/x86_64-linux

FROM redhat/ubi8-minimal:latest as installer
ARG TEXLIVE_DIR
ARG TL_MIRROR=https://mirror.ctan.org/systems/texlive/tlnet
ENV PATH=$TEXLIVE_BINARIES:$PATH
RUN microdnf install wget gzip tar perl
RUN mkdir install-tl && \
    wget "$TL_MIRROR/install-tl-unx.tar.gz" && \
    tar -xzf install-tl-unx.tar.gz -C install-tl --strip-components=1 && \
    ( \
        echo "selected_scheme scheme-full" && \
        echo "TEXDIR $TEXLIVE_DIR" && \
        echo "TEXMFCONFIG ~/.texlive/texmf-config" && \
        echo "TEXMFHOME ~/texmf" && \
        echo "TEXMFLOCAL $TEXLIVE_DIR/texmf-local" && \
        echo "TEXMFSYSCONFIG $TEXLIVE_DIR/texmf-config" && \
        echo "TEXMFSYSVAR $TEXLIVE_DIR/texmf-var" && \
        echo "TEXMFVAR ~/.texlive/texmf-var" && \
        echo "option_doc 0" && \
        echo "option_src 0" \
    ) > texlive.profile && \
    install-tl/install-tl --location $TL_MIRROR --profile texlive.profile

FROM redhat/ubi8-micro:latest
ARG TEXLIVE_DIR
ARG TEXLIVE_BINARIES
ENV PATH=$TEXLIVE_BINARIES:$PATH
COPY --from=installer $TEXLIVE_DIR $TEXLIVE_DIR
WORKDIR /app
ENTRYPOINT ["/bin/sh"]
