source api-key.sh

if [ -z "$SENDGRID_API_KEY" ]; then
    echo "SENDGRID_API_KEY is not set. Exiting."
    exit 1
fi

recipient_email="$1"
sender_email="$2"
subject="$3"
message="$4"

send_notification() {
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
}

send_notification "$recipient_email" "$sender_email" "$subject" "$message"
