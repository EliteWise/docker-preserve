#!/usr/bin/env bash

# Vérifier le premier argument
if [[ $1 == "config" ]]; then
    # Inclure le fichier config
    source config.sh
else
    # Vérifier que l'utilisateur a fourni les arguments nécessaires
    if [[ $# -lt 3 ]]; then
        echo "Usage: $0 [config] OR $0 [REMOTE_USER] [REMOTE_HOST] [REMOTE_PATH]"
        exit 1
    else
        # Configuration
        REMOTE_USER="$1"
        REMOTE_HOST="$2"
        REMOTE_PATH="$3"

        BACKUP_FOLDER="./backups"
        VOLUME_PATH="./volumes"
        BACKUP_FILE="backup_$(date +"%Y%m%d%H%M%S").tar.gz"
        BACKUP_PATH="$BACKUP_FOLDER/$BACKUP_FILE"

        SSH_KEY_PATH="/root/.ssh/backup-ssh"

        SETUP_CRON=false
        CRON_SCHEDULE="0 2 * * *"
    fi
fi



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

# Assurez-vous que la clé SSH a les bonnes permissions
chmod 600 "$SSH_KEY_PATH"

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"

if [ "$SETUP_CRON" = true ]; then
    if ! crontab -l | grep -q "path_to_your_script"; then
        (crontab -l ; echo "$CRON_SCHEDULE /bin/bash $SCRIPT_PATH/$(basename "$0")") | crontab -
        echo "Cron job configuré pour s'exécuter selon : $CRON_SCHEDULE"
    else
        echo "Cron job déjà configuré pour ce script."
    fi
fi

# Envoyer la sauvegarde au premier poste distant
scp -i "$SSH_KEY_PATH" $BACKUP_PATH $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH
if [[ $? -ne 0 ]]; then
    echo "Erreur lors de l'envoi de la sauvegarde au serveur distant."
    exit 1
fi

echo "Sauvegarde réussie et envoyée au serveur distant."
