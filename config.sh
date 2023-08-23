# Global Configuration
BACKUP_FOLDER="./backups"
VOLUME_PATH="./volumes"
VOLUME_NAME="volumes"
REMOTE_PATH="/home/ubuntu/backups"

BACKUP_FILE="backup_$(date +"%Y%m%d%H%M%S").tar.gz"
BACKUP_PATH="$BACKUP_FOLDER/$BACKUP_FILE"

# Configurations for the remote connection
REMOTE_USER="root"
REMOTE_HOST="example.com"

# SSH key configuration (if necessary)
SSH_KEY_PATH="/root/.ssh/backup-ssh"

# Cron Configuration
SETUP_CRON=false
CRON_SCHEDULE="0 2 * * *"

# Archive the directory on host mapped to the targeted volume
SAVE_BIND_MOUNTS=true
# Archive the persistent data storage in Docker of the targeted volume
SAVE_NAMED_VOLUMES=false

# Delete the most recent archive on the remote and parent server
DELETE_RECENT=false