#!/bin/bash

clear
############------------------------------------------------Define Functions------------------------------------------------############

clear
function load(){
        for i in range {1..3}
        do
                echo "."
                echo
                sleep .00001
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

############-----------------------------Loop and Reset Dates-----------------------------############

cat formatted.txt | awk ' { print $5 } ' | sed '/^$/d' > files-to-check.txt
number_of_files=$(wc -l files-to-check.txt | awk ' { print $1 } ')
prog=1
cat files-to-check.txt | while read line;
do
	echo "Scanning...("$prog" / "$number_of_files")"
	load
	exif_data=$(exiftool $dir/"$line" -php | grep "Date" | awk -F ':' ' { print $1 } ')
	if [[ $exif_data  == *'"DateTimeOriginal"'* ]]
	then
		date=$(exiftool $dir/"$line" -php | grep '"DateTimeOriginal"' | awk -F '"' ' { print $4 } ' | awk -F ":" ' { print $1 $2 $3 $4 } ' | sed s/\ //g)
		echo "Discovered (Date Time Original) for $line------$date"
	elif [[ $exif_data == *'"CreateDate"'* ]]
	then
		date=$(exiftool $dir/"$line" -php | grep '"CreateDate"' | awk -F '"' ' { print $4 } ' | awk -F ":" ' { print $1 $2 $3 $4 } ' | sed s/\ //g)
		echo "Discovered (Creation Date) for $line------$date"
	elif [[ $exif_data == *'"ModifyDate"'* ]]
        then        
		date=$(exiftool $dir/"$line" -php | grep '"ModifyDate"' | awk -F '"' ' { print $4 } ' | awk -F ":" ' { print $1 $2 $3 $4 } ' | sed s/\ //g)
                echo "Discovered (Modification Date) for $line------$date"
	elif [[ $exif_data == *'"FileModifyDate"'* ]]
        then
		date=$(exiftool $dir/"$line" -php | grep '"FileModifyDate"' | awk -F '"' ' { print $4 } ' | awk -F ":" ' { print $1 $2 $3 $4 } ' | sed s/\ //g)
                echo "Discovered (File Modification Date) for $line------$date"
	else
		echo "No Date Information Discovered..."
	fi
	touch -t $date $dir/"$line"
	#touch -m $dir/"$line"
	((prog+=1))
	load
done

############-----------------------------Clean Up-----------------------------############

mkdir -p date-reset-logs
mv formatted.txt date-reset-logs
mv files-to-check.txt date-reset-logs
mv dir-contents.txt date-reset-logs
load
echo "Completed"
