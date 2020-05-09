#!/bin/bash

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
load
echo "Scanning In Progress"
load

############-----------------------------Format Contents File (Leave only Name, Date, and Size)-----------------------------############

cat dir-contents.txt | awk ' { printf "%-8s %-5s %-5s %-7s %-20s\n", $5, $6 , $7, $8, $9} ' > formatted.txt

############--------------------------------------------------Housekeeping--------------------------------------------------############

echo "" > size-duplicates.txt
echo "" > date-duplicates.txt
echo "" > combined.txt
echo "" > Duplicates.txt

############-------------------------------------Find Potential Duplicates by File Size-------------------------------------############ 

cat formatted.txt | awk ' { print $1 } ' | sort | uniq -d > duplicate-sizes.txt
cat duplicate-sizes.txt | while read line;
do
	cat formatted.txt | grep $line >> size-duplicates.txt
done

############----------------------------------------Find Potential Duplicates by Date----------------------------------------############

cat formatted.txt | awk ' { printf "%-5s %-5s %-4s\n", $2, $3, $4 } ' | uniq -d > duplicate-dates.txt
cat duplicate-dates.txt | while read line;
do
        cat formatted.txt | grep "$line" >> date-duplicates.txt
done

############-----------------------------------------Combine Size & Date Duplicates-----------------------------------------############

cat size-duplicates.txt | awk ' { printf "%-8s %-5s %-5s %-4s\n", $1, $2, $3, $4 } ' >> combined.txt
cat date-duplicates.txt | awk ' { printf "%-8s %-5s %-5s %-4s\n", $1, $2, $3, $4 } ' >> combined.txt

############--------------------------------Cross Reference Both Lists for Repeat Offenders--------------------------------############

cat combined.txt | uniq -d > final-dups.txt
cat final-dups.txt | while read line;
do
        cat formatted.txt | grep "$line" >> Duplicates-Preclean.txt
done
	cat Duplicates-Preclean.txt | sort -u > Duplicates.txt

############---------------------------------------Move Extra Files to Log Directory---------------------------------------############

mkdir -p date-size-logs
mv duplicate-sizes.txt date-size-logs
mv duplicate-dates.txt date-size-logs
mv combined.txt date-size-logs
mv final-dups.txt date-size-logs
mv size-duplicates.txt date-size-logs
mv date-duplicates.txt date-size-logs
mv formatted.txt date-size-logs
mv dir-contents.txt date-size-logs
mv Duplicates-Preclean.txt date-size-logs

############----------------------------------Open Results File or Move Duplicates to Folder----------------------------------############

echo "Scan Completed, would you like to..."
load
echo "A) View the results file"
echo "B) Move the files to a folder named 'Duplicates Files' for review"
echo "C) Both of the above"
read action

case $action in
	[Aa] )
		load
		open Duplicates.txt
		;;
	[Bb] )
		load
		mkdir -p "Duplicates"
		files_to_move=$(cat Duplicates.txt | awk ' { print $5 } ')
		echo "Moving Files..."
		load
		for i in $files_to_move
		do
			mv $dir/$i Duplicates/
		done
		load
		echo "Files Have Been Moved to Folder for Review"
		;;
	[Cc] )
		load
                mkdir -p "Duplicates"
                files_to_move=$(cat Duplicates.txt | awk ' { print $5 } ')
                echo "Moving Files..."
                load
                for i in $files_to_move
                do
                        mv $dir/$i Duplicates/
                done
                load
                echo "Files Have Been Moved to Folder for Review"
                load
		open Duplicates.txt
		;;
esac
