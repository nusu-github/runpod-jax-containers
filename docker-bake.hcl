variable "RELEASE" {
    default = "1.0.0"
}

variable "GITHUB_WORKSPACE" {
    default = "."
}

target "default" {
    context = "${GITHUB_WORKSPACE}"
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64"]
    tags = ["nsrht/jax:25.10-py3-cuda13.0.2-ubuntu24.04"]
    contexts = {
        scripts = "container-template"
        proxy   = "container-template/proxy"
        logo    = "container-template"
    }
    args = {
        BASE_IMAGE = "nvcr.io/nvidia/jax:25.10-py3"
    }
}
