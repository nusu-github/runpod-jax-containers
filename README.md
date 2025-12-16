# RunPod NVIDIA JAX Container

This is a RunPod-optimized container for NVIDIA JAX, based on the official NVIDIA NGC image.

## What's included
- **JAX**: Pre-installed and optimized for NVIDIA GPUs (from `nvcr.io/nvidia/jax`).
- **RunPod Tools**: SSH, Jupyter Lab, Filebrowser, NGINX proxy.
- **CUDA**: 13.0.2 (from base image).
- **Python**: 3.12 (from base image).

## Usage

This container is designed to be used on RunPod. It starts an SSH server and Jupyter Lab automatically.

## Build Instructions

```bash
docker buildx bake
```

## Exposed Ports

- 22/tcp (SSH)
- 8888/tcp (Jupyter Lab)
