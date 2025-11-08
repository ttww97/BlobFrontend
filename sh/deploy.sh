#!/bin/bash
# Deployment script with fixed tar commands for drone-scp

set -euo pipefail

# Configuration
TAR_FILE="/tmp/dtSwNOTyAV.tar.gz"
WAR_FILE="BlobFrontend-1.0-SNAPSHOT.war"
ARTIFACTS_DIR="artifacts"
DEPLOY_DIR="/opt/blob-frontend/deploy"

echo "=== Creating tar archive ==="
# Fix: Use -C to change directory first, so tar doesn't include 'artifacts/' structure
if [ -f "${ARTIFACTS_DIR}/${WAR_FILE}" ]; then
    tar -zcf "${TAR_FILE}" -C "${ARTIFACTS_DIR}" "${WAR_FILE}"
    echo "✅ Tar file created: ${TAR_FILE}"
    echo "   Contents:"
    tar -tzf "${TAR_FILE}"
else
    echo "❌ WAR file not found: ${ARTIFACTS_DIR}/${WAR_FILE}"
    exit 1
fi

echo ""
echo "=== Deployment commands for remote server ==="
echo ""
echo "1. Create deploy directory:"
echo "   sudo mkdir -p ${DEPLOY_DIR}"
echo "   sudo chown \$USER:\$USER ${DEPLOY_DIR}"
echo ""
echo "2. Extract tar file:"
echo "   tar -zxf dtSwNOTyAV.tar.gz --overwrite -C ${DEPLOY_DIR}/"
echo ""
echo "3. Verify:"
echo "   ls -lh ${DEPLOY_DIR}/${WAR_FILE}"
echo ""
echo "=== Tar file ready for SCP ==="
echo "File: ${TAR_FILE}"
ls -lh "${TAR_FILE}"

