#!/bin/bash

#activate enviroment
source muzube-env/bin/activate

#get date from file
source muzube.conf

#set mac if it isn't already
if [ -z "$MacAdress" ]
then
	MacAdress=$(od -vAn -N8 -tu8 < /dev/urandom |md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/'|tr '[:lower:]' '[:upper:]')
	sed -i -e "s/MacAdress=/MacAdress=$MacAdress/" muzube.conf
fi

#make folder if not exists
mkdir -p songs
#go into folder
cd songs

#download all the songs!
echo Downloading songs
youtube-dl --dateafter $LastDownloaded --playlist-end $SongLimit \
	--max-filesize 50m --extract-audio --audio-format $Format \
	--output "%(title)s.%(ext)s" $Playlist

#give all the songs the right tags
echo Tagging songs
for i in *
do
	if test -f "$i"
	then
		ARTIST=$(echo $i | sed 's/\(.*\) - .*\.mp3/\1/')
		SONG=$(  echo $i | sed 's/.* - \(.*\)\.mp3/\1/')
		ALBUM=$Album
		id3v2 --artist="$ARTIST" --album="$ALBUM" --song="$SONG" "$i"
	fi
done
echo end tagging
#return a folder
cd ..
#upload songs to google music
./gmusicapi-scripts/gmupload.py --uploader-id $MacAdress --match songs/*

#remove uploaded songs
rm songs/*

#update date
sed -i -e "s/LastDownloaded=.*/LastDownloaded=$(date +%Y%m%d)/" muzube.conf

deactivate
