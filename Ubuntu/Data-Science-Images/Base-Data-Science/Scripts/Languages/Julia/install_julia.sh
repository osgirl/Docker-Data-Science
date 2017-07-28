#!/bin/bash
set -e

mkdir $JULIA_HOME && cd /tmp \
&& curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%[.-]*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -o julia.tar.gz \
&& curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%[.-]*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz.asc" -o julia.tar.gz.asc \
&& export GNUPGHOME="$(mktemp -d)" \
&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 3673DF529D9049477F76B37566E3C7DC03D6E495 \
&& gpg --batch --verify julia.tar.gz.asc julia.tar.gz \
&& rm -r "$GNUPGHOME" julia.tar.gz.asc \
&& tar -xzf julia.tar.gz -C $JULIA_PATH --strip-components 1 \
&& rm -rf /var/lib/apt/lists/* julia.tar.gz*

su - $DATASCI_USER - c "bash /tmp/install_julia_base_pkgs.sh"