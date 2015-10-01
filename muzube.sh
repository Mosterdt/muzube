#!/bin/bash

#activate enviroment
source muzube-env/bin/activate

#get date from file
source muzube.conf

#make folder if not exists
mkdir -p songs
#go into folder
cd songs

#download all the songs!
echo Downloading songs
youtube-dl --dateafter $LastDownloaded --playlist-end 10 \
	--extract-audio --audio-format $Format \
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
		id3tag --artist=$ARTIST --album=$ALBUM --song=$SONG "$i"
	fi
done

#return a folder
cd ..
#upload songs to google music
./gmusicapi-scripts/gmupload.py -m songs/*

#remove uploaded songs
rm songs/*

#update date
sed -i.bak -e "s/LastDownloaded=.*/LastDownloaded=$(date +%Y%m%d)/" muzube.conf

deactivate
