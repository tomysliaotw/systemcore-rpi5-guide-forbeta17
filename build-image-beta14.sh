#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with: sudo ./build-image-beta14.sh"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$REPO_DIR/cache"

RELEASE_TAG="limelightosr-2027.0.0-beta14-210"
ZIP_NAME="limelightsystemcorebetacm5-limelightosr-beta-14.zip"
ZIP_PATH="$CACHE_DIR/$ZIP_NAME"
IMAGE_MEMBER="limelightsystemcorebetacm5.img"
OUTPUT_IMAGE="$REPO_DIR/systemcore-pi5b-beta14-patched.img"

IMAGE_URL="https://github.com/LimelightVision/systemcore-os-public/releases/download/${RELEASE_TAG}/limelightsystemcorebetacm5-limelightosr-2027.0.0-beta14.zip"

mkdir -p "$CACHE_DIR"

if [[ -e "$OUTPUT_IMAGE" ]]; then
  echo "Refusing to overwrite existing output:"
  echo "  $OUTPUT_IMAGE"
  exit 1
fi

if [[ ! -f "$ZIP_PATH" ]] || ! unzip -tqq "$ZIP_PATH" >/dev/null 2>&1; then
  echo "[1/4] Downloading SystemCore Beta 14 image..."
  rm -f "$ZIP_PATH"
  wget -O "$ZIP_PATH" "$IMAGE_URL"
else
  echo "[1/4] Valid upstream ZIP already cached."
fi

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
CLEAN_IMAGE="$TEMP_DIR/systemcore-beta14-clean.img"

echo "[2/4] Extracting clean upstream image..."
unzip -p "$ZIP_PATH" "$IMAGE_MEMBER" > "$CLEAN_IMAGE"

echo "[3/4] Patching Beta 14 image..."
echo "      Beta 14 has no rootfs B, so patching A only."
python3 "$REPO_DIR/patch-image.py" \
  "$CLEAN_IMAGE" \
  -o "$OUTPUT_IMAGE" \
  --skip-b \
  --validate

if [[ -n "${SUDO_USER:-}" ]]; then
  chown "$SUDO_USER":"$SUDO_USER" "$OUTPUT_IMAGE"
fi

echo "[4/4] Done:"
echo "      $OUTPUT_IMAGE"
