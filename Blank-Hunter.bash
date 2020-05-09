#!/bin/bash

clear
############------------------------------------------------Define Functions------------------------------------------------############

clear
function load(){
        for i in range {1..3}
        do
                echo "."
                echo
                sleep .02
        done
}


############------------------Ask user if they want to specify a directory to scan or use the current one------------------############

current_dir=$(pwd)
echo "WARNING, FILENAMES CANNOT CONTAIN SPACES"
echo
echo "Current working directory is $current_dir"
load
echo "Is this the correct directory to scan?"
load
echo "[Y] or [N]"
read choice
case $choice in
        [Nn] )
                load
                echo "Enter directory to scan:"
		echo
                read dir
		load
                echo "Prepping scan for $dir"
                load
                ;;
        [Yy] )
                load
                echo "Prepping current directory for scan"
                load
                ;;
esac

############-----------------------------------------List Directory Contents to File-----------------------------------------############

ls -l $dir > dir-contents.txt

############-----------------------------Format Contents File (Leave only Name, Date, and Size)-----------------------------############

cat dir-contents.txt | awk ' { printf "%-8s %-5s %-5s %-7s %-20s\n", $5, $6 , $7, $8, $9} ' > formatted.txt

############-----------------------------Loop and Hunt for Files with Lots of Zeros-----------------------------############
mkdir -p "Blank-Files"
cat formatted.txt | awk ' { print $5 } ' > files-to-check.txt
number_of_files=$(wc -l files-to-check.txt | awk ' { print $1 } ')
prog=1
cat files-to-check.txt | while read line;
do
	hex=$(hexdump -d -n256 $dir/"$line" | grep "0000000")
	echo "Scanning------("$prog" / "$number_of_files")"
	if [[ $hex == "0000000   00000   00000   00000   00000   00000   00000   00000   00000" ]]
	then
		mv $dir/"$line" Blank-Files/
		echo "Found One..."
	else
		echo
	fi
	((prog+=1))
done

############-----------------------------Clean Up-----------------------------############

mkdir -p hex-hunter-logs
mv formatted.txt hex-hunter-logs
mv files-to-check.txt hex-hunter-logs
mv dir-contents.txt hex-hunter-logs
load
echo "Completed"
