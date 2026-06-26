#!/bin/bash

# Build script for Xiaomi 13 (fuxi) kernel
# Supports two variants: clean (no KSU/SUSFS) and ksu (with KernelSU Next + SUSFS)

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR"

# Available branches
CLEAN_BRANCH="main"
KSU_BRANCH="ksu"

usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  switch <variant>    Switch kernel source to variant (clean/ksu)"
    echo "  build               Build kernel Image and dtb"
    echo "  build-all           Build ROM with current kernel variant"
    echo "  status              Show current branch and variant"
    echo ""
    echo "Variants:"
    echo "  clean               Kernel without KernelSU/SUSFS"
    echo "  ksu                 Kernel with KernelSU Next + SUSFS v2.2.0"
    echo ""
    echo "Examples:"
    echo "  $0 switch clean     # Switch to clean kernel"
    echo "  $0 switch ksu       # Switch to KSU kernel"
    echo "  $0 build            # Build current kernel"
    echo "  $0 build-all        # Build full ROM"
}

get_current_variant() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    case "$branch" in
        "$CLEAN_BRANCH") echo "clean" ;;
        "$KSU_BRANCH")   echo "ksu" ;;
        *)               echo "unknown ($branch)" ;;
    esac
}

cmd_switch() {
    local variant="${1:-}"
    case "$variant" in
        clean)
            echo "Switching to clean kernel (no KSU/SUSFS)..."
            git checkout "$CLEAN_BRANCH"
            echo "Now on branch: $CLEAN_BRANCH (variant: clean)"
            ;;
        ksu)
            echo "Switching to KSU kernel (KernelSU Next + SUSFS v2.2.0)..."
            git checkout "$KSU_BRANCH"
            echo "Now on branch: $KSU_BRANCH (variant: ksu)"
            ;;
        *)
            echo "Error: Unknown variant '$variant'. Use 'clean' or 'ksu'."
            exit 1
            ;;
    esac
}

cmd_build() {
    local variant
    variant=$(get_current_variant)
    echo "Building kernel variant: $variant"
    echo "Branch: $(git rev-parse --abbrev-ref HEAD)"

    # Check if we're in an Android build environment
    if [ -z "$ANDROID_BUILD_TOP" ]; then
        echo ""
        echo "WARNING: Android build environment not detected."
        echo "Run these commands first:"
        echo "  source build/envsetup.sh"
        echo "  breakfast fuxi"
        echo ""
        echo "Or use 'build-all' to build the full ROM."
        exit 1
    fi

    echo "Building boot + init_boot images..."
    m bootimage init_bootimage 2>&1 || {
        echo "Build failed! Try 'build-all' for full ROM build."
        exit 1
    }
    echo "Images built:"
    ls -la $ANDROID_BUILD_TOP/out/target/product/fuxi/boot.img $ANDROID_BUILD_TOP/out/target/product/fuxi/init_boot.img 2>/dev/null
}

cmd_build_all() {
    local variant
    variant=$(get_current_variant)
    echo "Building full ROM with kernel variant: $variant"
    echo "Branch: $(git rev-parse --abbrev-ref HEAD)"

    # Check if we're in an Android build environment
    if [ -z "$ANDROID_BUILD_TOP" ]; then
        echo "Error: Android build environment not detected."
        echo "Run: source build/envsetup.sh && breakfast fuxi"
        exit 1
    fi

    echo "Starting full ROM build..."
    m pixelos 2>&1 || {
        echo "ROM build failed!"
        exit 1
    }
    echo "ROM build complete."
}

cmd_status() {
    local branch variant
    branch=$(git rev-parse --abbrev-ref HEAD)
    variant=$(get_current_variant)

    echo "Current branch: $branch"
    echo "Current variant: $variant"
    echo ""
    echo "Available branches:"
    echo "  $CLEAN_BRANCH - Clean kernel (no KSU/SUSFS)"
    echo "  $KSU_BRANCH   - KSU kernel (KernelSU Next + SUSFS v2.2.0)"
}

# Main
case "${1:-}" in
    switch)     cmd_switch "${2:-}" ;;
    build)      cmd_build ;;
    build-all)  cmd_build_all ;;
    status)     cmd_status ;;
    -h|--help)  usage ;;
    *)          usage; exit 1 ;;
esac
