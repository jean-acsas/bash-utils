#!bin/bash
cd /home/path/to/directory
now=`date +" %d.%m.%Y-%H:%M"`
filename="SOME_ZIP_NAME_$now.zip"
zip -r "$filename" .
mv "$filename" /home/path/to/Dropbox/subdirectory/
~/.dropbox-dist/dropboxd


