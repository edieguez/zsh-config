#! /usr/bin/env bash
set -euo pipefail

# Check for API Layer token
if [[ -z "$API_LAYER_TOKEN" ]]; then
    echo "API_LAYER_TOKEN variable not set. Get a token from https://exchangeratesapi.io"
    exit 1
fi

if [ $# == 0 ]; then
    echo "Usage: $(basename $0) <amount> <from> <to>"
    exit 2
fi

declare -i amount="$1"
declare -r from="${2:-USD}"
declare -r to="${3:-MXN}"

result=$(curl --silent --request GET \
    --url "https://api.apilayer.com/exchangerates_data/convert?from=$from&to=$to&amount=$amount" \
    --header "apikey: $API_LAYER_TOKEN" | jq -r '.result')


message=$(printf "%'.2f $from is %'.2f $to\n" $amount $result)

echo $message
