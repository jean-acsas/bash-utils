#!/bin/bash

# Attempts to decompose an sql file to csv. 
#
# You have to change the maxline variable and run the script
# with the sql file as argument: ./split.sh data.sql
# Backup you files before executing! I'm not responsible for
# any data loss! Also, check the output files for errors!

outdir="output/" # folder to save the output files
maxline=65530 # maximum number of lines per csv file

# working variables
zero=0
one=1
linecount=1
filename=""
fileno=0
cleaned=""
totalline=0
totalmaxline=$(wc -l < $1) # total number of lines (progress indicator)
# Uncomment if you want one record per file regardless of size
#~ maxline="$totalmaxline" 

# if directory doesn't exist, create it 
if [ ! -d "$outdir" ] ; then
mkdir "$outdir"
fi

# cleans a line from ( ) `, I kept the ' character because 
# it is used as text delimiter
clean_line() {
  cleaned=$(echo $1 | sed "s/(\|)\|\`//g") 
  return 0
}

# prints the cleaned line into a file 
# if the file is not full (no of rows less than $maxline)
# else it starts spliting in files
print_line() {
  let linecount=$linecount+1
  if [ "$linecount" -lt "$maxline" ]; then
    if [ "$fileno" -eq "$zero" ] ; then
  echo "$1" >> "${outdir}${filename}.csv"
 else
     echo "$1" >> "${outdir}${filename}-${fileno}.csv"
 fi
  else
 let fileno=$fileno+1
 linecount=1
 if [ -f "${outdir}${filename}-${fileno}.csv" ] ; then
  rm "${outdir}${filename}-${fileno}.csv"
  #~ echo "removing ${filename}-${fileno}.csv"
 fi
 echo "$1" >> "${outdir}${filename}-${fileno}.csv"
  fi
  return 0
}

# Main procedure 
echo -n "          "
while read line; do
    echo -n -e "\b\b\b\b\b\b\b\b\b\b"         # erase last printed thing
 let totalline=$totalline+1                      # increment progress
 percent=$((100 * $totalline / $totalmaxline))    # calculate percent
 printf "%4s%% done" $percent                   # print formatted per
    clean_line "$line"
    A=$(echo $line| awk '{ print $1 }')
    if [ "$A" == "INSERT" ]; then
  A=$(echo $cleaned | awk '{ print $3 }')
  if [ ! "$A" == "$filename" ]; then
   filename="$A"
   if [ -f "${outdir}${filename}.csv" ] ; then
    rm "${outdir}${filename}.csv"
    #~ echo "removing ${filename}.csv"
   fi
   linecount=0
   fileno=0
   A=$(echo $cleaned | sed "s/$A//g")
   A=$(echo $A | sed 's/INSERT//g')
   A=$(echo $A | sed 's/INTO//g')
   A=$(echo $A | sed 's/VALUES//g')
   print_line "$A"
  fi
 elif [ "${A:0:1}" == "(" ]; then
  print_line "$cleaned" 
    fi
done < "$1"
echo ""
