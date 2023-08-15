#!/usr/bin/env bash

# Vérifier que l'utilisateur a fourni les arguments nécessaires
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 [REMOTE_USER] [REMOTE_HOST] [REMOTE_PATH]"
    exit 1
fi

# Configuration
BACKUP_FOLDER="./backups"
VOLUME_PATH="./volumes"
BACKUP_FILE="backup_$(date +"%Y%m%d%H%M%S").tar.gz"
BACKUP_PATH="$BACKUP_FOLDER/$BACKUP_FILE"

REMOTE_USER="$1"
REMOTE_HOST="$2"
REMOTE_PATH="$3"

# Vérifiez si le dossier backups existe, sinon créez-le
if [[ ! -d "./backups" ]]; then
    mkdir "./backups"
    if [[ $? -ne 0 ]]; then
        echo "Erreur lors de la création du dossier 'backups'."
        exit 1
    fi
fi

# Créer une archive du dossier "volumes"
sudo tar czvf $BACKUP_PATH -C $VOLUME_PATH ./
if [[ $? -ne 0 ]]; then
    echo "Erreur lors de la création de l'archive."
    exit 1
fi

# Envoyer la sauvegarde au premier poste distant
scp $BACKUP_PATH $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH
if [[ $? -ne 0 ]]; then
    echo "Erreur lors de l'envoi de la sauvegarde au serveur distant."
    exit 1
fi

echo "Sauvegarde réussie et envoyée au serveur distant."
