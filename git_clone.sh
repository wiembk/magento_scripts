# DESCRIPTION: Clone repository and add submodules, Install database and use it with magento 
#!/bin/bash

FILE_ID="fileID_drive"
database_name="wamia.zip.gz"
GDOWN_PATH="$HOME/.local/bin/gdown"
TGT_USER='xxx'
TGT_PASS='xxxx'
TGT_DB='wamia'
TGT_DOMAIN='localhost'




# Check if gdown is already installed
if command -v gdown &>/dev/null; then
  echo "gdown is already installed."
else
  echo "Installing gdown..."
  pip install gdown || { echo "Error: Failed to install gdown." >&2; exit 1; }
fi

# Download the database file
"$GDOWN_PATH" --id "$FILE_ID" --output "$database_name"

# Optional: Check if the download was successful
if [ $? -eq 0 ]; then
  echo "Database downloaded successfully."
else
  echo "Error downloading the database."
fi

#
sudo mysql -u $TGT_USER -p$TGT_PASS -e "CREATE DATABASE $TGT_DB;"
gunzip < $database_name | mysql --max_allowed_packet=512M -u $TGT_USER -p$TGT_PASS $TGT_DB 

#

