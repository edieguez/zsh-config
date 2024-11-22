#! /usr/bin/env bash

validate() {
  if [ $# -lt 2 ]; then
  echo "Usage: $0 <to> <body>"
  exit 1
  fi

  if [ -z "$TWILIO_ACCOUNT_SID" ]; then
    echo "TWILIO_ACCOUNT_SID is not set. Exiting."
    exit 2
  fi

  if [ -z "$TWILIO_AUTH_TOKEN" ]; then
    echo "TWILIO_AUTH_TOKEN is not set. Exiting."
    exit 3
  fi

  if [ -z "$TWILIO_NUMBER" ]; then
    echo "TWILIO_NUMBER is not set. Exiting."
    exit 4
  fi
}

validate $@

TO=$1
BODY=$2

curl --silent -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" \
  --data-urlencode "Body=$BODY" \
  --data-urlencode "From=$TWILIO_NUMBER" \
  --data-urlencode "To=$TO" \
  -u "$TWILIO_AUTH_TOKEN" | jq
