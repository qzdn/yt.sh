#!/bin/sh

NEWSBOAT_DIR="$HOME/.config/newsboat"
URLS_FILE="$NEWSBOAT_DIR/urls"

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
    local rss_url="$1"
    local newsboat_username="$2"

    # Delete entry, if it exists
    sed -i "\|$rss_url|d" "$URLS_FILE"

    if sed -i "/\"query:YouTube:(tags # \\\\\"youtube\\\\\")\"/a $rss_url youtube \"~$newsboat_username\" \!" "$URLS_FILE"; then
        return 0
    else
        return 1
    fi
}

#####

echo "Getting channel RSS..."
#rss_url=$(curl -s "https://www.youtube.com/@$1" | grep -o 'rssUrl":"[^"]*' | cut -d'"' -f3)
rss_url="https://www.youtube.com/feeds/videos.xml?channel_id=$(yt-dlp -I1 --print channel_id https://www.youtube.com/@$1)" # longer, but w/o curl
echo $rss_url

if [ -z "$rss_url" ]; then
    echo "Error: could not get RSS URL for https://www.youtube.com/@$1"
    exit 1
fi

echo "Found RSS link: $rss_url"

check_newsboat_query_feed

if add_channel_to_newsboat "$rss_url" "$1"; then
    echo "Channel was successfully added."
    exit 0
else
    echo "Error on channel addition."
    exit 1
fi
