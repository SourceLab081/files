#!/bin/bash
# Originally taken from : wget -q "https://raw.githubusercontent.com/pouriya3/telegram-file-uploader/refs/heads/main/install.sh" -O install.sh && bash install.sh
# BOT_TOKEN="xxxxxyyyyyyyyy:AANNNNNNMMMMMNN"
# CHAT_ID="-yyyyyyyyyxxxxxxxxxx"

if [ $# -eq 0 ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File '$FILE_PATH' not found."
  exit 1
fi

if ! command -v curl &> /dev/null; then
  echo "Error: curl is not installed . please first install curl"
  exit 1
fi

curl -s -X POST \
  "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
  -H "Content-Type: multipart/form-data" \
  -F "chat_id=$CHAT_ID" \
  -F "document=@$FILE_PATH" \
  -F "caption=$(basename "$FILE_PATH")"

if [[ $(echo "$?") -ne 0 ]]; then
  echo "Error: File upload failed"
  exit 1
fi

echo "File '$FILE_PATH' sent to Telegram"

exit 0
