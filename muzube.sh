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
mkdir -p msssongs
#go into folder
cd msssongs

#download all the songs!
echo Downloading songs
youtube-dl --dateafter $LastDownloaded --playlist-end $SongLimit \
	--max-filesize 50m --extract-audio --audio-format $Format \
	--output "%(title)s.%(ext)s" $mssPlaylist

#give all the songs the right tags
echo Tagging songs
for i in *
do
	if test -f "$i"
	then
		ARTIST=$(echo $i | sed 's/\(.*\) - .*\.mp3/\1/')
		SONG=$(  echo $i | sed 's/.* - \(.*\)\.mp3/\1/')
		ALBUM="$mssAlbum"
		id3v2 --artist="$ARTIST" --album="$ALBUM" --song="$SONG" "$i"
	fi
done
echo end tagging
#return a folder
cd ..
#upload songs to google music
./gmusicapi-scripts/gmupload.py --uploader-id $MacAdress --match msssongs/*

#remove uploaded songs
rm msssongs/*

#-----------xKito music-----------------------

#make folder if not exists
mkdir -p xksongs
mkdir -p mislukt
#go into folder
cd xksongs

#download all the songs!
echo Downloading songs
youtube-dl --dateafter $LastDownloaded --playlist-end $SongLimit \
	--max-filesize 50m --extract-audio --audio-format $Format \
	--output "%(title)s.%(ext)s" $xkPlaylist

#give all the songs the right tags
echo Tagging songs
for i in *
do
	if test -f "$i"
	then
		if echo $i | grep --quiet "【.*】.*-.*" 
		then
		
		ARTIST=$(echo $i | sed 's/【\(.*\)】\(.*\) - \(.*\)/\2/')
		SONG=$(  echo $i | sed 's/【\(.*\)】\(.*\) - \(.*\)/\3/')
		GENRE=$( echo $i | sed 's/【\(.*\)】\(.*\) - \(.*\)/\1/')
		ALBUM=$xkAlbum
		id3v2 --artist="$ARTIST" --album="$ALBUM" --song="$SONG" --genre="$GENRE" "$i"
		else
			echo "geen geldig liedje"
			mv $i ../mislukt/
		fi
	fi
done
echo end tagging
#return a folder
cd ..
#upload songs to google music
./gmusicapi-scripts/gmupload.py --uploader-id $MacAdress --match xksongs/*

#remove uploaded songs
rm xksongs/*


#update date
sed -i -e "s/LastDownloaded=.*/LastDownloaded=$(date +%Y%m%d)/" muzube.conf

deactivate
