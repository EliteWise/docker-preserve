source api-key.sh

if [ -z "$SENDGRID_API_KEY" ]; then
    echo "SENDGRID_API_KEY is not set. Exiting."
    exit 1
fi

send_notification() {
  local recipient_email="$1"
  local sender_email="$2"
  local subject="$3"
  local message="$4"

  curl --request POST \
       --url https://api.sendgrid.com/v3/mail/send \
       --header "Authorization: Bearer $SENDGRID_API_KEY" \
       --header 'Content-Type: application/json' \
       --data "{
           \"personalizations\": [
               {
                   \"to\": [
                       {
                           \"email\": \"$recipient_email\"
                       }
                   ]
               }
           ],
           \"from\": {
               \"email\": \"$sender_email\"
           },
           \"subject\": \"$subject\",
           \"content\": [
               {
                   \"type\": \"text/plain\", 
                   \"value\": \"$message\"
               }
           ]
       }"

    return 0
}