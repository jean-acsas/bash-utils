## Bash Cheatsheet

### Working with files locally

#### Recursively delete all empty (sub-)directories
Usage:
```Bash
find . -type d -empty -delete
```
using ` -print` will also print the deleted directories

#### Find total size of all files within a specific size range

Tip: use `tail -1` to get the last line, otherwise all lines/files with their sizes will be printed plus the last (total) one.

Example:
```Bash
find . -maxdepth 1 -size +20M -size -100M -exec du -c {} + | tail -1
```
Output (in bytes):
```Bash
53962064	total
```
####  ... and the number of files within a size range
```Bash
find . -maxdepth 1 -size +22M -size -100M | wc -l
```
#### ... move them to a directory (or do something else) using a loop
As script:

```Bash
#!/bin/bash
find . -maxdepth 1 -size +22M -size +100M | while read file; do

# here we are compressing a pdf
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -sOutputFile=compressed/"$file" "$file"

# here we are copying
cp someDir/"$file" someDir/..

done
```
Ass one-liner:
```Bash
find . -maxdepth 1 -size +22M -size -100M | while read file; do mv "$file" filesBetween21and100/; done
```

#### Copy all files with a specific ending to a target directory
```Bash
find . -name \*.sh -exec cp {} bashScripte/ \;
```
### Transferring files between systems

#### Copy a directory to another system (here ...1.8 is the target system)
```Bash
scp -r filesBetween21and100/ bonjeano@192.168.1.8:/home/bonjeano/pdfsToShrink
```
#### Copy a file from a remote server to the local system
```Bash
scp root@myServerIp:/path/to/file.sh /home/bonjeano/Desktop/
```
#### Wait for incoming files and then then process them, otherwise sleep.
In this example a server acts as a processor for pdfs files:
```Bash
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
```
### Misc

#### Get space available in partition in this directory
General:
```Bash
df -k .
```
example:
```Bash
df -k .
Filesystem     1K-blocks    Used Available Use% Mounted
/dev/sda3       62331644 6372644  52762944  11% /
```
