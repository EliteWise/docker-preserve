# Configurations générales
BACKUP_FOLDER="./backups"
VOLUME_PATH="./volumes"
VOLUME_NAME="volumes"
REMOTE_PATH="/home/ubuntu/backups"

BACKUP_FILE="backup_$(date +"%Y%m%d%H%M%S").tar.gz"
BACKUP_PATH="$BACKUP_FOLDER/$BACKUP_FILE"

# Configurations pour la connexion distante
REMOTE_USER="root"
REMOTE_HOST="example.com"

# Configuration clé SSH (si nécessaire)
SSH_KEY_PATH="/root/.ssh/backup-ssh"

SETUP_CRON=false
CRON_SCHEDULE="0 2 * * *"

SAVE_BIND_MOUNTS=true
SAVE_NAMED_VOLUMES=false
