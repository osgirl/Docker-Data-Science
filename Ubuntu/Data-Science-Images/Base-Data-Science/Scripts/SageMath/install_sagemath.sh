#!/bin/bash
set -e

# Install Sage math
apt-add-repository -y ppa:aims/sagemath && apt-get update && apt-get --yes install sagemath-upstream-binary
chown -R $DATASCI_USER:$DATASCI_USER $SAGE_ROOT
mkdir -p $HOME/.sage
chown -R $DATASCI_USER:$DATASCI_USER $HOME/.sage && chmod -R 775 $HOME/.sage

mkdir -p /usr/local/share/jupyter && chown -R $DATASCI_USER:$DATASCI_USER $JUPYTER_SHARE
chown -R $DATASCI_USER:$DATASCI_USER $JUPYTER_SHARE
mkdir -p $USER_JUPYTER_KERNELS && chown -R $DATASCI_USER:$DATASCI_USER $USER_JUPYTER_KERNELS

su  - $DATASCI_USER && $CONDA_BIN/jupyter kernelspec install $SAGE_ROOT/local/share/jupyter/kernels/sagemath && \
$SAGE_ROOT/local/bin/python2.7 -m pip install ipykernel && \
$SAGE_ROOT/local/bin/python2.7 -m ipykernel install && exit