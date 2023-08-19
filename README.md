# Docker Backup Script

This script facilitates the creation of a compressed archive of your "volumes" directory and sends it to a remote server using SCP.

### Prerequisites
- docker, tar, and scp should be installed on your machine.
- SSH key-based access set up for the remote server, ensuring password-less authentication.

### Usage
Firstly, ensure the script has execution permissions. Then, run it with the correct parameters:
```sh
chmod +x docker-volumes-backup.sh
./docker-volumes-backup.sh [REMOTE_USER] [REMOTE_HOST] [REMOTE_PATH]
```

Where:

- [REMOTE_USER] is the username on the remote server.
- [REMOTE_HOST] is the address or hostname of the remote server.
- [REMOTE_PATH] is the directory path on the remote server where you wish to store the backup.

Example:
```sh
./docker-volumes-backup.sh root 10.11.12.13 /home/ubuntu/backups
```

#### Points to Note
- Ensure the "volumes" directory resides in the same directory as the script.
- The script will create a "backups" directory in the current directory if it doesn't already exist, temporarily storing the compressed archive there before transferring.
- Make sure you have adequate disk space for the compressed archive in the "backups" directory.
- Ensure proper permissions to read from the "volumes" directory and write to the "backups" directory.
