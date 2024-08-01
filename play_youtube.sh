#!/bin/bash

# ID de la playlist de YouTube (cambia este ID por el correcto)
PLAYLIST_ID="PL5vXZMBWYVkPACU409MVu08SMG8ePe3WS"

# URL de la playlist de YouTube
PLAYLIST_URL="https://www.youtube.com/playlist?list=${PLAYLIST_ID}"

# Crear un archivo temporal para la lista de URLs
TEMP_LIST=$(mktemp)

# Obtener la lista de videos de la playlist y extraer URLs de streaming en calidad 480p
yt-dlp --flat-playlist -i --get-id "$PLAYLIST_URL" | sort -R | while read -r VIDEO_ID; do
  # Intentar obtener la URL de streaming en calidad 480p
  URL=$(yt-dlp -f 'best[height=480]' -g "https://www.youtube.com/watch?v=${VIDEO_ID}" 2>/dev/null)
  
  # Si no se pudo obtener la calidad 480p, intentar obtener el mejor formato disponible
  if [ -z "$URL" ]; then
    URL=$(yt-dlp -f 'best' -g "https://www.youtube.com/watch?v=${VIDEO_ID}" 2>/dev/null)
  fi

  if [ -n "$URL" ]; then
    echo "$URL"
  else
    echo "Error: no se pudo obtener la URL para el video con ID $VIDEO_ID." >&2
  fi
done > "$TEMP_LIST"

# Verificar que la lista de URLs se haya creado y no esté vacía
if [ ! -s "$TEMP_LIST" ]; then
  echo "Error: no se pudo obtener la lista de URLs o la lista está vacía."
  exit 1
fi

# Reproducir los URLs con mpv en bucle
mpv --playlist="$TEMP_LIST" --loop=inf

# Limpiar el archivo temporal
rm "$TEMP_LIST"
