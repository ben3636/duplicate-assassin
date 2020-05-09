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

#echo "" > hashlist.txt

tail -n +2 dir-contents.txt | awk ' { printf "%-8s %-5s %-5s %-7s %-20s\n", $5, $6 , $7, $8, $9} ' > formatted.txt

############-----------------------------Create File List-----------------------------############

cat formatted.txt | awk ' { print $5 } ' > files.txt
number_of_files=$(wc -l files.txt | awk ' { print $1 } ')

############-----------------------------Create Metadata Files & Hash If Needed-----------------------------############

prog=1
mkdir -p metadata-files
cat files.txt | while read line;
do
        if [[ -f "metadata-files/$line.txt" ]]
        then
                echo "Metadata Export File Already Exists for $line..."
		#hash=$(md5 metadata-files/"$line".txt | awk ' { print $4 } ')
		#echo "$hash--$dir/$line" >> hashlist.txt
        else
                #This line is more accurate but sometimes misses potential duplicates with slightly different metadata
		#exiftool $dir/"$line" -php | sed /"SourceFile"/d | sed /"FileName"/d | sed /"Date"/d > metadata-files/"$line".txt

                exiftool $dir/"$line" -php | sed /"SourceFile"/d | sed /"FileName"/d | sed /"Date"/d | sed /"ExifByteOrder"/d | sed /"FileSize"/d | sed /"ThumbnailImage"/d | \
		sed /"ThumbnailLength"/d | sed /"ThumbnailOffset"/d | sed /"About"/d | sed /"LastKeywordXMP"/d | sed /"OffsetSchema"/d | \
		sed /"Padding"/d | sed /"Subject"/d  | sed /"ComponentsConfiguration"/d | sed /"YCbCrPositioning"/d | sed /"ExifVersion"/d > metadata-files/"$line".txt

		echo "Exporting/Hashing Metadata for $line------("$prog" / "$number_of_files")"
                hash=$(md5 metadata-files/"$line".txt | awk ' { print $4 } ')
                echo "$hash--$dir/$line" >> hashlist.txt
        fi
        ((prog+=1))
done

############-----------------------------Check for Duplicate Hashes & Match to Filename-----------------------------############

load
echo "Scanning Hash Values for Matches"
load
echo "" > DUPS.txt
dup_hashes=$(cat hashlist.txt | awk -F "--" ' { print $1 } ' | sort | uniq -d)
prog=1
cat hashlist.txt | while read line;
do
	echo "Scanning--------("$prog" / "$number_of_files")"
        hash=$(echo "$line" | awk -F "--" ' { print $1 } ')
        name=$(echo "$line" | awk -F "--" ' { print $2 } ')
        echo "$name--$hash" > check-line.txt
        if [[ "$dup_hashes" == *"$hash"* ]]
        then
                cat check-line.txt >> DUPS.txt
        fi
	((prog+=1))
done

############-----------------------------Move Duplicate Files to Folder-----------------------------############

mkdir -p Duplicates
tail -n +3 DUPS.txt | awk -F "--" ' { print $1 } ' | while read line;
do
	mv $line Duplicates/
done
load
echo "Potential Duplicates Have Been Moved to New Folder"
load
echo "BOTH files in each potential duplicate pair are in the folder for review"
load
echo "You will have to choose the ones to keep manually. Sorting by size or date can make this faster"
load
echo "Program Completed" 

############-----------------------------Clean Up-----------------------------############

mkdir -p hash-logs
mv files.txt hash-logs
mv formatted.txt hash-logs
mv check-line.txt hash-logs
mv hashlist.txt hash-logs
mv dir-contents.txt hash-logs
mv metadata-files hash-logs
mv DUPS.txt hash-logs
