#!/usr/bin/env bash

# Configuration
VOLUME_NAME="volumes"
BACKUP_FOLDER="."
BACKUP_FILE="backup_$(date +"%Y%m%d%H%M%S").tar.gz"
BACKUP_PATH="$BACKUP_FOLDER/$BACKUP_FILE"

REMOTE_USER="root"
REMOTE_HOST="$1"
REMOTE_PATH="/home/ubuntu/backups"

# Récupérer le chemin du répertoire du volume
VOLUME_PATH=$(docker volume inspect $VOLUME_NAME --format '{{.Mountpoint}}')

# Créer une archive du volume
sudo tar czvf $BACKUP_PATH -C $VOLUME_PATH ./

# Envoyer la sauvegarde au premier poste distant
scp $BACKUP_PATH $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH
