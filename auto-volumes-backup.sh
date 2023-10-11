#!/usr/bin/env bash
(

dependencies=("tar" "scp" "ssh" "docker")
# Verify the existence of dependencies
for cmd in "${dependencies[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    echo "Erreur : $cmd n'est pas installé."
    exit 1
  fi
done

# Verify the first argument
if [[ $1 == "config" ]]; then
    # Include config script
    source config.sh
else
    # Verify that the user passed enough arguments
    if [[ $# -lt 3 ]]; then
        echo "Usage: $0 [config] OR $0 [REMOTE_USER] [REMOTE_HOST] [REMOTE_PATH]"
        exit 1
    else
      if [[ ! "$1" =~  "-" ]]; then
        # Configuration
        REMOTE_USER="$1"
        REMOTE_HOST="$2"
        REMOTE_PATH="$3"
      else
        FLAG_PASSED=true

        BACKUP_FOLDER="./backups"
        VOLUME_PATH="./volumes"
        BACKUP_FILE="backup_$(date +"%Y%m%d%H%M%S").tar.gz"
        BACKUP_PATH="$BACKUP_FOLDER/$BACKUP_FILE"

        SSH_KEY_PATH="/root/.ssh/backup-ssh"

        SETUP_CRON=false
        CRON_SCHEDULE="0 2 * * *"

        SAVE_BIND_MOUNTS=true
        SAVE_NAMED_VOLUMES=false

        DELETE_RECENT=false

        for arg in "$@"; do
          if [ "$arg" == '--named-volumes' ]; then
              SAVE_NAMED_VOLUMES=true
              break
          fi
        done
      fi
    fi
fi

if [[ "$FLAG_PASSED" = true ]]; then
  while getopts ":u:r:p:" opt; do
    case ${opt} in
      u)
        REMOTE_USER="$OPTARG"
        ;;
      r)
        REMOTE_HOST="$OPTARG"
        ;;
      p)
        REMOTE_PATH="$OPTARG"
        ;;
      h)
        echo "Usage:"
        echo "  $0 config"
        echo "  $0 REMOTE_USER REMOTE_HOST REMOTE_PATH [--named-volumes]"
        echo "  $0 -u REMOTE_USER -r REMOTE_HOST -p REMOTE_PATH [--named-volumes]"
        echo ""
        echo "Options:"
        echo "  config            Use the configuration file to execute the script."
        echo "  REMOTE_USER       Username to use for the remote connection."
        echo "  REMOTE_HOST       IP address or hostname of the remote server."
        echo "  REMOTE_PATH       Path on the remote server where operations will be performed."
        echo "  --named-volumes   Use named volumes for persistent storage with docker (optional)."
        exit 1
        ;;
      \?)
        echo "Option invalide: -$OPTARG" 1>&2
        exit 1
        ;;
      :)
        echo "L'option -$OPTARG requiet un argument." 1>&2
        exit 1
        ;;
    esac
  done
fi

# Verify if the folder backups exist, else create it
if [[ ! -d "./backups" ]]; then
    mkdir "./backups"
    if [[ $? -ne 0 ]]; then
        echo "Erreur lors de la création du dossier 'backups'."
        exit 1
    fi
fi

if [[ "$SAVE_NAMED_VOLUMES" = true ]]; then
  if docker volume ls -q | grep -q "^${VOLUME_NAME}$"; then
    # Creation of an archive of the volume
    sudo tar -czvf "${BACKUP_PATH}" -C "/var/lib/docker/volumes/${VOLUME_NAME}/_data" .
    if [[ $? -eq 0 ]]; then
      echo "Archive créée avec succès dans ${BACKUP_PATH}"
    else
      echo "Erreur lors de la création de l'archive."
    fi
  else
      echo "Le volume $VOLUME_NAME n'existe pas."
  fi
fi

# Creation of an archive of the folder "volumes"
case "$COMPRESSED_PROGRAM" in 
  gzip)
    # z to use gzip compression
    sudo tar czvf "$BACKUP_PATH.gz" -C "$VOLUME_PATH" ./
  ;;
  xz)
    # J to use xz compression
    sudo tar cJvf "$BACKUP_PATH.xz" -C "$VOLUME_PATH" ./
  ;;
  bzip2)
    # j to use bzip2 compression
    sudo tar cjvf "$BACKUP_PATH.bz2" -C "$VOLUME_PATH" ./
  ;;
  7zip)
    sudo 7z a -t7z "$BACKUP_PATH.7z" "$VOLUME_PATH" ./
  ;;
esac

if [[ $? -ne 0 ]]; then
    echo "Erreur lors de la création de l'archive."
    exit 1
else
    if [[ "$DELETE_RECENT" = true ]]; then
      PREVIOUS_ARCHIVE=$(ls -lt "$BACKUP_PATH"/*.tar.gz | head -n 2 | tail -n 1 | awk '{print $NF}')

      if [[ -n "$PREVIOUS_ARCHIVE" && -f "$PREVIOUS_ARCHIVE" ]]; then
        rm "$PREVIOUS_ARCHIVE"
        if [[ $? -eq 0 ]]; then
          echo "Suppression de la dernière archive effectuée."
        else
          echo "Erreur lors de la suppression de l'archive."
        fi
      else
        echo "L'archive précédente n'a pas été trouvée ou n'est pas un fichier régulier."
      fi
    fi
fi

if ! [ -f $SSH_KEY_PATH ]; then
  ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH"

  # Verify if the SSH key as the right permissions
  chmod 600 "$SSH_KEY_PATH"

  # Copy the public key to the remote server
  ssh-copy-id -i "$SSH_KEY_PATH".pub $REMOTE_USER@$REMOTE_HOST

  # Modify the remote server's SSH configuration to disable password authentication
  ssh -i "$SSH_KEY_PATH" $REMOTE_USER@$REMOTE_HOST "sudo sed -i 's/^#PasswordAuthentication yes$/PasswordAuthentication no/' /etc/ssh/sshd_config && sudo systemctl restart sshd"
fi

if [[ "$SETUP_CRON" = true ]]; then
    SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
    if ! crontab -l | grep -q $SCRIPT_PATH; then
        (crontab -l ; echo "$CRON_SCHEDULE /bin/bash $SCRIPT_PATH/$(basename "$0")") | crontab -
        echo "Cron job configuré pour s'exécuter selon : $CRON_SCHEDULE"
    else
        echo "Cron job déjà configuré pour ce script."
    fi
fi

# Send the save to the first remote server/computer
scp -i "$SSH_KEY_PATH" $BACKUP_PATH $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH
if [[ $? -ne 0 ]]; then
    echo "Erreur lors de l'envoi de la sauvegarde au serveur distant."
    exit 1
fi

source notifications-sender.sh

send_notification "florent.mogenet@gmail.com" "exp@gmail.com" "Subject" "Message"
if [[ $? -ne 0 ]]; then
  echo "Erreur lors de l'envoi du mail."
  exit 1
fi

if [[ "$DELETE_RECENT" = true ]]; then
  # Delete the oldest archives on the remote server
  ssh -i "$SSH_KEY_PATH" $REMOTE_USER@$REMOTE_HOST <<EOF
  cd $REMOTE_PATH

  # Get the timestamp of the most recently updated/uploaded folder
  newest_timestamp=$(stat --format=%Y -- "$(ls -t | head -n 1)")

  # Scans each file/folder to check its timestamp
  for file in *; do
    file_timestamp=$(stat --format=%Y -- "$file")

    # If the file/folder is older than the most recent, delete it.
    if [[ $file_timestamp -lt $newest_timestamp ]]; then
      rm -r "$file"
    fi
  done
EOF
fi

echo "Sauvegarde réussie et envoyée au serveur distant."

# Redirects standard and error output to the "output.log" file
) |& tee output.log
