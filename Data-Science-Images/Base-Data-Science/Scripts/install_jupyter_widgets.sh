# $CONDA_BIN/conda install --yes mathjax
$CONDA_BIN/conda install --yes --channel damianavila82 rise

# Configure kernels
$CONDA_BIN/jupyter-nbextension install rise --py --sys-prefix
$CONDA_BIN/jupyter-nbextension enable rise --py --sys-prefix
$CONDA_BIN/jupyter-nbextension enable widgetsnbextension --py --sys-prefix
$CONDA_BIN/conda install --yes jupyter_dashboards -c conda-forge