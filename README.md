Bash Cheatsheet

------
recursively delete all empty (sub-)directories:
find . -type d -empty -delete 

-> mit -print wird auch noch angezeigt welche gelöscht werden

-----
find total size of all files within a specific size range ( tail -1 to get the last line, otherwise all lines/files with their sizes will be printed plus the last (total) one)

example:
find . -maxdepth 1 -size +20M -size -100M -exec du -c {} + | tail -1
53962064	total

----
... and the number of files within a size range
find . -maxdepth 1 -size +22M -size -100M | wc -l

... move them to a directory (or do something else) using a loop

-> as script 

#!/bin/bash 
find . -maxdepth 1 -size +22M -size +100M | while read file; do 

# here we are compressing
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -sOutputFile=compressed/"$file" "$file"

# here we are copying
cp someDir/"$file" someDir/..

done

-> as one-liner
find . -maxdepth 1 -size +22M -size -100M | while read file; do mv "$file" filesBetween21and100/; done

-----
get space available in partition in this directory
df -k .

example: 
$ df -k .
Filesystem     1K-blocks    Used Available Use% Mounted
/dev/sda3       62331644 6372644  52762944  11% /

-----
copy directory via scp to another computer (here ...1.8 is the target computer)
scp -r filesBetween21and100/ bonjeano@192.168.1.8:/home/bonjeano/pdfsToShrink 

-----
wait for incoming files and then process then, otherwise sleep (if you do not want to wait until all files are transmitted to the server / processing computer)

!/bin/bash

# here we could set a timeout variable and use it below using tries=$((tries+1))
# nonstop
while : ; do
        #check wether pdfs exist
        count=$(ls -1 *.pdf 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
          wait
          # if yes, loop through an process them
          for pdf in *.pdf; do
            echo "shrinking $pdf"
            gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -sOutputFile=shrinked/"$pdf" "$pdf"
            # remove so the later check for pdfs will take effect
            rm "$pdf"
          done
        # otherwise sleep
        else
           echo "Pausing until next file exists."
           sleep 5
        fi
done

--- 
copy all files with a specific ending to a target directory 

sudo find . -name \*.sh -exec cp {} bashScripte/ \;

