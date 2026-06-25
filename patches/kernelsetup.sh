#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Resolve the ROOT directory ---
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." &> /dev/null && pwd)"
echo "--- Running script from: $SCRIPT_DIR"
echo "--- Kernel root directory: $ROOT_DIR"

# Define paths
KSU_NEXT_DIR="$ROOT_DIR/KernelSU-Next"
# pershoot's KernelSU-Next with built-in SUSFS v2.2.0
KSU_NEXT_REPO="https://github.com/pershoot/KernelSU-Next.git"
KSU_NEXT_BRANCH="dev-susfs"

# --- Function to setup KernelSU-Next with SUSFS v2.2.0 ---
setup_ksu_next() {
    echo "--- Setting up KernelSU-Next with SUSFS v2.2.0 ---"

    cd "$ROOT_DIR"

    # Step 1: Clone KernelSU-Next from pershoot's fork (SUSFS built-in)
    if [ -d "$KSU_NEXT_DIR" ]; then
        echo "--- Directory $KSU_NEXT_DIR exists. Cleaning up for a fresh clone..."
        rm -rf "$KSU_NEXT_DIR"
    fi

    echo "--- Cloning KernelSU-Next from pershoot (dev-susfs branch)..."
    git clone -b "$KSU_NEXT_BRANCH" --depth=1 "$KSU_NEXT_REPO" "$KSU_NEXT_DIR"

    # Step 2: Remove .git to store as regular files
    rm -rf "$KSU_NEXT_DIR/.git"

    echo ""
    echo "KernelSU-Next with SUSFS v2.2.0 is ready."
    echo "SUSFS is built-in, no separate patches needed."
}

# --- Main ---
echo ""
echo "Setting up KernelSU-Next with SUSFS v2.2.0..."
echo ""

setup_ksu_next
