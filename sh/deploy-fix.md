# Drone-SCP Deployment Fix

## Problem
The tar command includes the `artifacts/` directory structure, causing permission errors when extracting on the remote server.

## Solution

### Option 1: Fix the tar creation (Recommended)
Change the tar creation command to exclude the `artifacts/` directory structure:

**Before (incorrect):**
```bash
tar -zcf /tmp/dtSwNOTyAV.tar.gz artifacts/BlobFrontend-1.0-SNAPSHOT.war
```

**After (correct):**
```bash
tar -zcf /tmp/dtSwNOTyAV.tar.gz -C artifacts BlobFrontend-1.0-SNAPSHOT.war
```

The `-C artifacts` flag changes to the `artifacts/` directory before creating the tar, so the archive contains only the file without the directory structure.

### Option 2: Fix the extraction
If you can't change the tar creation, use `--strip-components=1` when extracting:

**Before (incorrect):**
```bash
tar -zxf dtSwNOTyAV.tar.gz --overwrite -C /opt/blob-frontend/deploy/
```

**After (correct):**
```bash
tar -zxf dtSwNOTyAV.tar.gz --strip-components=1 --overwrite -C /opt/blob-frontend/deploy/
```

The `--strip-components=1` flag removes the first directory level (`artifacts/`) from the extracted paths.

## Complete Fixed Commands

### Step 1: Create tar file (with fix)
```bash
tar -zcf /tmp/dtSwNOTyAV.tar.gz -C artifacts BlobFrontend-1.0-SNAPSHOT.war
```

### Step 2: SCP to server
```bash
# This is handled by drone-scp plugin
```

### Step 3: Create deploy directory
```bash
sudo mkdir -p /opt/blob-frontend/deploy
sudo chown $USER:$USER /opt/blob-frontend/deploy
```

### Step 4: Extract tar file
```bash
tar -zxf dtSwNOTyAV.tar.gz --overwrite -C /opt/blob-frontend/deploy/
```

### Step 5: Verify
```bash
ls -lh /opt/blob-frontend/deploy/BlobFrontend-1.0-SNAPSHOT.war
```

## Drone CI Configuration Example

If you're using drone-scp plugin, your `.drone.yml` should look like:

```yaml
- name: create-tar
  image: alpine
  commands:
    - tar -zcf /tmp/dtSwNOTyAV.tar.gz -C artifacts BlobFrontend-1.0-SNAPSHOT.war

- name: scp-to-server
  image: appleboy/drone-scp
  settings:
    host:
      from_secret: server_host
    username:
      from_secret: server_user
    key:
      from_secret: server_ssh_key
    source:
      - /tmp/dtSwNOTyAV.tar.gz
    target: /tmp/
    strip_components: 0
    overwrite: true

- name: extract-and-deploy
  image: appleboy/drone-ssh
  settings:
    host:
      from_secret: server_host
    username:
      from_secret: server_user
    key:
      from_secret: server_ssh_key
    script:
      - sudo mkdir -p /opt/blob-frontend/deploy
      - sudo chown $USER:$USER /opt/blob-frontend/deploy
      - tar -zxf /tmp/dtSwNOTyAV.tar.gz --overwrite -C /opt/blob-frontend/deploy/
      - ls -lh /opt/blob-frontend/deploy/BlobFrontend-1.0-SNAPSHOT.war
      - rm -f /tmp/dtSwNOTyAV.tar.gz
```

