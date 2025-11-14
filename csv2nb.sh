#!/bin/sh

NEWSBOAT_DIR="$HOME/.config/newsboat"
URLS_FILE="$NEWSBOAT_DIR/urls"
CSV_FILE="$1"

if [ -z "$CSV_FILE" ]; then
    echo "Usage: $0 subscriptions.csv"
    exit 1
fi

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: '$CSV_FILE' not found."
    exit 1
fi

if [ ! -f "$URLS_FILE" ]; then
  read -p "'$URLS_FILE' was not found. Create it? [Y/n] " confirm
  case "$confirm" in
    [yY]|[yY][eE][sS]|"")
      mkdir -p "$NEWSBOAT_DIR"
      touch "$URLS_FILE"
      echo "Creating '$URLS_FILE'..."
      ;;
    *)
      echo "'$URLS_FILE' wasn't created."
      exit 1
      ;;
  esac
fi

# Create query feed if it doesn't exist
check_newsboat_query_feed() {
    if ! grep -qF '"query:YouTube:(tags # \"youtube\")"' "$URLS_FILE"; then
        echo "Query feed in $URLS_FILE was not found. Creating..."
        echo '' >> "$URLS_FILE"
        echo '"query:YouTube:(tags # \"youtube\")"' >> "$URLS_FILE"
    fi
}

add_channel_to_newsboat() {
    local channel_id="$1"
    local channel_name="$2"
    local rss_url="https://www.youtube.com/feeds/videos.xml?channel_id=$channel_id"
    
    # Check if entry already exists
    if grep -qF "$rss_url" "$URLS_FILE"; then
        return 1  # Return error code to indicate skipped
    fi
    
    # Add channel feed
    sed -i "/\"query:YouTube:(tags # \\\\\"youtube\\\\\")\"/a $rss_url youtube \"~$channel_name\" \!" "$URLS_FILE"
    return 0  # Success
}

#####

echo "CSV file: '$CSV_FILE'"
echo "newsboat urls: '$URLS_FILE'"

check_newsboat_query_feed

# Counters
total=0
imported=0
skipped=0

# Process CSV file
while IFS=, read -r channel_id url channel_name; do
  channel_id=$(echo "$channel_id" | tr -d '"' | tr -d '\r')
  channel_name=$(echo "$channel_name" | sed 's/^"//;s/"$//' | tr -d '\r')
  
  if [ -z "$channel_id" ] || [ -z "$channel_name" ]; then
  	echo "Empty line, skipping..."
    skipped=$((skipped + 1))
    total=$((total + 1))
    continue
  fi

  # Escape special characters for newsboat format
  channel_name_escaped=$(echo "$channel_name" | sed 's/\\/\\\\/g; s/"/\\"/g')
  
  echo "Importing: $channel_name ($channel_id)"
  if add_channel_to_newsboat "$channel_id" "$channel_name_escaped"; then
    imported=$((imported + 1))
  else
    echo "  Already exists, skipping..."
    skipped=$((skipped + 1))
  fi
  total=$((total + 1))
done < <(tail -n +2 "$CSV_FILE")

echo ""
echo "Processed: $total channels"
echo "Imported: $imported channels"
echo "Skipped: $skipped channels"
