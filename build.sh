#!/usr/bin/env bash
# ==============================================================================
# Gaming OS - Build Orchestration Script
# Supports: Local Docker Build, Native Archiso Build, and Workspace Clean
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUT_DIR="${SCRIPT_DIR}/out"

BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

usage() {
    echo -e "${BOLD}Usage:${RESET} $0 [docker|native|clean]"
    echo ""
    echo "  ${CYAN}docker${RESET}   - Build ISO inside a Docker container (Recommended for Windows / non-Arch systems)"
    echo "  ${CYAN}native${RESET}   - Build ISO directly on an Arch Linux / Arch-WSL2 host (requires root/sudo)"
    echo "  ${CYAN}clean${RESET}    - Clean up build cache, work directories, and temporary files"
    echo ""
    exit 1
}

clean_build() {
    echo -e "${CYAN}==> Cleaning build artifacts...${RESET}"
    if [ -d "$WORK_DIR" ]; then
        if command -v sudo &>/dev/null && [ "$EUID" -ne 0 ]; then
            sudo rm -rf "$WORK_DIR"
        else
            rm -rf "$WORK_DIR"
        fi
    fi
    echo -e "${GREEN}==> Clean complete.${RESET}"
}

build_docker() {
    echo -e "${CYAN}==> Building Gaming OS via Docker container...${RESET}"
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}Error: Docker is not installed or not in PATH.${RESET}"
        exit 1
    fi

    mkdir -p "$OUT_DIR"

    echo -e "${CYAN}==> Building Docker image (gaming-os-builder)...${RESET}"
    docker build -t gaming-os-builder -f "${SCRIPT_DIR}/Dockerfile" "${SCRIPT_DIR}"

    echo -e "${CYAN}==> Running ISO build inside privileged container...${RESET}"
    docker run --rm --privileged \
        -v "${OUT_DIR}:/build/out" \
        gaming-os-builder

    echo -e "${GREEN}==> Build finished! ISO is located in:${RESET} ${OUT_DIR}/"
    ls -lh "${OUT_DIR}/"
}

build_native() {
    echo -e "${CYAN}==> Building Gaming OS natively via mkarchiso...${RESET}"
    
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Native mkarchiso requires root privileges. Please run with sudo.${RESET}"
        exit 1
    fi

    if ! command -v mkarchiso &>/dev/null; then
        echo -e "${RED}Error: mkarchiso is not installed. Run: pacman -S archiso${RESET}"
        exit 1
    fi

    mkdir -p "$WORK_DIR" "$OUT_DIR"

    echo -e "${CYAN}==> Invoking mkarchiso...${RESET}"
    mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$SCRIPT_DIR"

    echo -e "${GREEN}==> Build finished successfully!${RESET}"
    ls -lh "${OUT_DIR}/"
}

MODE="${1:-}"

case "$MODE" in
    docker)
        build_docker
        ;;
    native)
        build_native
        ;;
    clean)
        clean_build
        ;;
    "")
        # Auto-detect best mode
        if [ -f /etc/arch-release ]; then
            echo -e "${CYAN}Arch Linux detected. Defaulting to native build...${RESET}"
            build_native
        elif command -v docker &>/dev/null; then
            echo -e "${CYAN}Docker detected. Defaulting to Docker build...${RESET}"
            build_docker
        else
            usage
        fi
        ;;
    *)
        usage
        ;;
esac
