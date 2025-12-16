ARG BASE_IMAGE=nvcr.io/nvidia/jax:25.10-py3
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    SHELL=/bin/bash

# Set the default workspace directory
ENV RP_WORKSPACE=/workspace

# RunPod specific environment variables
ENV HF_HOME="${RP_WORKSPACE}/.cache/huggingface/" \
    VIRTUALENV_OVERRIDE_APP_DATA="${RP_WORKSPACE}/.cache/virtualenv/" \
    PIP_CACHE_DIR="${RP_WORKSPACE}/.cache/pip/" \
    UV_CACHE_DIR="${RP_WORKSPACE}/.cache/uv/"
# uv settings for container environment
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never \
    UV_SYSTEM_PYTHON=1
# Python and library settings
ENV TF_FORCE_GPU_ALLOW_GROWTH=true \
    MPLBACKEND=module://matplotlib_inline.backend_inline \
    PAGER=cat \
    GIT_PAGER=cat \
    CLICOLOR=1 \
    PYTHONWARNINGS=ignore:::pip._internal.cli.base_command \
    PYTHONUTF8=1 \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    HF_XET_HIGH_PERFORMANCE=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PYTHONUNBUFFERED=True \
    TZ=Etc/UTC

WORKDIR /

# Update and install tools needed for Runpod and general ML development
# Included are build tools, media libraries, network tools, and editors
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    build-essential ca-certificates cifs-utils cmake curl dirmngr dnsutils ffmpeg \
    file gfortran git gpg gpg-agent inetutils-traceroute inotify-tools iputils-ping jq \
    libatlas-base-dev libavcodec-dev libavfilter-dev libavformat-dev libblas-dev libffi-dev \
    libgl1 libhdf5-dev libjpeg-dev liblapack-dev libnuma-dev libpng-dev libpostproc-dev \
    libsm6 libssl-dev libswscale-dev libtiff-dev libv4l-dev libx264-dev libxrender-dev \
    libxvidcore-dev lsof make mtr nano nfs-common nginx openssh-server rsync slurm-wlm \
    software-properties-common sudo tmux unzip vim wget zip zstd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install filebrowser
RUN curl -LsSf https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Install Python packages: Grain, Optax, Jupyter, and other development tools using uv
# --system flag is required to install into the system python environment
# --break-system-packages is required on newer Ubuntu versions (PEP 668)
RUN uv pip install --system --break-system-packages \
    "grain==0.2.12" \
    "optax==0.2.6" \
    jupyterlab \
    ipywidgets \
    jupyter-archive \
    "notebook==7.4.2" \
    pandas \
    matplotlib \
    scipy \
    scikit-learn \
    tqdm \
    pyyaml \
    requests \
    pillow \
    opencv-python-headless \
    einops \
    wandb \
    tensorflow-datasets \
    transformers \
    datasets \
    safetensors \
    huggingface_hub

# Remove existing SSH host keys to ensure unique keys are generated at runtime
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy Configuration
COPY --from=proxy nginx.conf /etc/nginx/nginx.conf
COPY --from=proxy snippets /etc/nginx/snippets
COPY --from=proxy readme.html /usr/share/nginx/html/readme.html

# Copy Container README
COPY README.md /usr/share/nginx/html/README.md

# Start Script
COPY --from=scripts --chmod=755 start.sh /

# Welcome Message
COPY --from=logo runpod.txt /etc/runpod.txt
RUN echo 'cat /etc/runpod.txt' >> /root/.bashrc
RUN echo 'echo -e "\nFor detailed documentation and guides, please visit:\n\033[1;34mhttps://docs.runpod.io/\033[0m and \033[1;34mhttps://blog.runpod.io/\033[0m\n\n"' >> /root/.bashrc

CMD ["/start.sh"]
