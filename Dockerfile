# ==============================================================================
# Gaming OS - Reproducible Archiso Docker Builder
# ==============================================================================
FROM archlinux:base-devel

LABEL maintainer="Gaming OS Project"
LABEL description="Archiso build container for Gaming OS"

# Initialize Pacman keyring & mirrors
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Syu --noconfirm \
        archiso \
        git \
        curl \
        wget \
        dosfstools \
        e2fsprogs \
        squashfs-tools \
        libisoburn \
        mtools \
        binutils

# Set up build workspace
WORKDIR /build

# Entrypoint script that builds the ISO with mkarchiso
COPY . /build/profile

RUN chmod +x /build/profile/build.sh 2>/dev/null || true

CMD ["bash", "-c", "mkdir -p /build/out /build/work && mkarchiso -v -w /build/work -o /build/out /build/profile"]
