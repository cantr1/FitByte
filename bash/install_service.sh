#!/usr/bin/env bash
# Install or update FitByte as a systemd service.
# Configure bash/env_vars before running this script.
set -euo pipefail

readonly SERVICE_NAME="fitbyte.service"
readonly SERVICE_USER="fitbyte"
readonly SERVICE_DIR="/opt/fitbyte"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
readonly ENV_FILE="$SCRIPT_DIR/env_vars"
readonly UNIT_FILE="$SCRIPT_DIR/$SERVICE_NAME"
readonly WEB_DIR="$REPO_DIR/web"
readonly BUILD_OUTPUT="/tmp/fitbyte"

if (( EUID != 0 )); then
    echo "Run this script with sudo: sudo $0" >&2
    exit 1
fi

for path in "$ENV_FILE" "$UNIT_FILE" "$WEB_DIR"; do
    if [[ ! -e "$path" ]]; then
        echo "Required deployment input not found: $path" >&2
        exit 1
    fi
done

trap 'rm -f -- "$BUILD_OUTPUT"' EXIT
(
    cd "$REPO_DIR"
    go build -o "$BUILD_OUTPUT" .
)

if ! id "$SERVICE_USER" >/dev/null 2>&1; then
    NOLOGIN_SHELL="$(command -v nologin 2>/dev/null || true)"
    NOLOGIN_SHELL="${NOLOGIN_SHELL:-/usr/sbin/nologin}"
    useradd --system --home-dir "$SERVICE_DIR" --shell "$NOLOGIN_SHELL" "$SERVICE_USER"
fi

systemctl is-active --quiet "$SERVICE_NAME" && systemctl stop "$SERVICE_NAME"

install -d -m 0755 "$SERVICE_DIR"
install -d -m 0755 "$SERVICE_DIR/web"
install -m 0755 "$BUILD_OUTPUT" "$SERVICE_DIR/fitbyte"
install -o "$SERVICE_USER" -m 0400 "$ENV_FILE" "$SERVICE_DIR/.env"
cp -R "$WEB_DIR/." "$SERVICE_DIR/web/"
chown -R root:root "$SERVICE_DIR/web"
chmod -R u=rwX,go=rX "$SERVICE_DIR/web"
install -m 0644 "$UNIT_FILE" "/etc/systemd/system/$SERVICE_NAME"

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

# Give the process a moment to expose immediate startup failures.
sleep 1
if ! systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Service failed to start. Current status:" >&2
    systemctl --no-pager --full status "$SERVICE_NAME" || true
    exit 1
fi

echo "FitByte installed successfully and is running."
