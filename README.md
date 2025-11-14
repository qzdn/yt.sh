# yt.sh 

Watch YouTube w/o browser - with mpv, yt-dlp and newsboat (for subsciptions).

## Installation

```bash
# Install mpv, newsboat and yt-dlp with your package manager
$ sudo pacman -S mpv newsboat yt-dlp

# Clone repo
$ git clone https://github.com/qzdn/yt.sh.git
$ cd yt.sh/ 
$ chmod +x channel2nb.sh csv2nb.sh search2mpv.sh
```

## Scripts

### channel2nb.sh

Add channel to `newsboat` manually by username (`https://www.youtube.com/@username`):

```bash
$ ./channel2nb.sh username
```

Check it in `.config/newsboat/urls`.

### csv2nb.sh

Imports your subscriptions to `newsboat` from `csv` file.

1. Go to [Google Takeout](https://takeout.google.com/) and export your YouTube subscriptions to `csv` file.
2. Download it to the folder with scripts.
3. Run `./csv2nb.sh filename.csv`.

Check `.config/newsboat/urls` for imported entries.

### search2mpv.sh

Watch videos by search requests:

```bash
$ ./search2mpv.sh rick roll
```

You can set up quantity of search results or video quality in the script itself.

## newsboat config

1. Add this macros to your `newsboat` config (`.config/newsboat/config`):

  ```
  macro y ; set browser "mpv --volume=80 --no-cache --vo=gpu --hwdec=auto --ytdl-format='bestvideo[vcodec^=avc1][height<=720][fps<=30]+bestaudio/bestvideo+bestaudio/best'" ; open-in-browser ; set browser "links %u"
  macro Y ; set browser "mpv --volume=80 --no-cache --ytdl-format='bestaudio'" ; open-in-browser ; set browser "links %u"
  ```
  
  You can edit `mpv` launch parameters for your needs.

2. Open `newsboat`, refresh your feeds, open "YouTube" feed, select any video and press `,y` or `,Y` for audio only.


