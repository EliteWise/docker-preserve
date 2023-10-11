# Global Configuration
BACKUP_FOLDER="./backups"
VOLUME_PATH="./volumes"
VOLUME_NAME="volumes"
REMOTE_PATH="/home/elite/backups"

BACKUP_FILE="backup_$(date +"%Y%m%d%H%M%S").tar"
BACKUP_PATH="$BACKUP_FOLDER/$BACKUP_FILE"

# Configurations for the remote connection
REMOTE_USER="root"
REMOTE_HOST="example.com"

# SSH key configuration (if necessary)
SSH_KEY_PATH="~/.ssh/id_rsa_backups"

# Cron Configuration
SETUP_CRON=false
CRON_SCHEDULE="0 2 * * *"

# Archive the directory on host mapped to the targeted volume
SAVE_BIND_MOUNTS=true
# Archive the persistent data storage in Docker of the targeted volume
SAVE_NAMED_VOLUMES=false

# Delete the most recent archive on the remote and parent server
DELETE_RECENT=false

# List of programs supported: gzip | xz | bzip2 | 7zip
COMPRESSION_PROGRAM="7zip"