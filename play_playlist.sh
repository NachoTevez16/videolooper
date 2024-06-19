playlist_url=https://www.youtube.com/playlist?list=PL5vXZMBWYVkPACU409MVu08SMG8ePe3WS

#descarga la playlist en json
yt-dlp -J --flat-playlist "$playlist_url" > playlist_data.json

#procesa el json con python para sacar las urls
python3 - << EOF
import sys
import json

with open('playlist_data.json', 'r') as f:
	data = json.load(f)

urls = [f'https://www.youtube.com/watch?v={entry["id"]}' for entry in data['entries']]

with open('playlist.txt', 'w') as f:
	for url in urls:
		f.write(f"{url}\n")
EOF

#mezclo las url
shuf playlist.txt > playlist_random.txt

echo "EXTM3U" > playlist.m3u8
cat playlist_random.txt | while read url; do
	echo "EXTINF:-1, Youtube Video"
	echo "$url"
done >> playlist.m3u8

cvlc --no-video-title-show --quiet --loop --preferred-resolution=480 playlist.m3u8