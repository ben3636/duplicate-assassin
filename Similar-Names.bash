#!/bin/bash

#########------------------------------------Define Functions------------------------------------#########
clear
function load(){
        for i in range {1..3}
        do
                echo "."
                echo
                sleep .001
        done
}

#########------------------------------------Usage Info Warning------------------------------------#########
echo "WARNING: THIS SCRIPT IS DESIGNED TO WORK ONLY WITH FILES WITHOUT SPACES IN THE NAMES"
load
echo "If filenames contain spaces, use the batch rename option to change spaces to '~x~' (without quotes)"
load
echo "This is used as a temporary substitute for spaces that can be changed back after the program has completed"
load
load
echo "Have all spaces in filenames been changed to '~x~'?"
echo
echo "[Y] or [N]:"
echo
read choice
case $choice in
        [Nn] )
                load
                echo "Exiting..."
		sleep 1
		load
		exit 0
                ;;
        [Yy] )
                load
                echo "Prepping for scan..."
                load
                ;;
esac

#########------------------------------------List Directory Contents // Initialize Files------------------------------------#########
ls > ls.txt
echo "" > sim-list.txt
mkdir -p SIMS
mkdir -p ORIGINALS


##########################################################Check for Similarity##########################################################

#########---------------------------Run Through Directory Searching for Similar File Names---------------------------#########
cat ls.txt | sort -r | while read line;
do
	######------If Filename Contains Space Char------######
	if [[ $line == *"~x~"* ]]
	then
	
	        ######------Isolate Name from Space Char------######
		name=$(echo $line | sed s/"~x~"//)

                ######------If Name Contains (), Remove It ------######
		if [[ $name == *"("*")"* ]]
                then
                        name=$(echo $name | sed s/"(".")"// | awk -F "." ' { print $1 } ')
                fi

        	######------Search Directory for Similar Names------######
		sims=$(cat ls.txt | grep "$name" | sed s/^"$line"//)
		matches=()

	        ######------If No Similars Found, Continue------######
		if [[ $sims == "" ]]
		then
			:

	        ######------If Similars Found, Check if Sizes Match------######
		else
			original_size=$(ls -l $line | awk ' { print $5 } ')
			for i in $sims
			do
				size=$(ls -l $i | awk ' { print $5 } ')
				if [[ $size == $original_size ]]
				then
					matches+=( $i )		
				fi
			done

	       		######------If Any Similars Pass Size Check, Show Them------######
			if [[ ${matches[@]} != "" ]]
			then				
                                echo "------------------------------"
		               	echo "Name is...$name"
				echo "------------------------------"
				echo "                              |"
				echo "                               ----"
				echo "                                   |"
				echo "                                   V"
				#echo $name >> sim-list.txt
				echo "				Similars			       "
				echo " ------------------------------------------------------------------------"
				echo "|                                                                        |"
				for i in ${matches[@]}
				do
					echo $i
					mv $line ORIGINALS/     #Move the original file to a folder
					mv $i SIMS/ 	#Move the similar files to a folder
					part1=$(echo $line | awk -F "." ' { print $1 } ')
					part2=$(echo $line | awk -F "." ' { print "."$2 } ')
					mv SIMS/$i SIMS/"$part1(Duplicate-ID-$RANDOM)$part2"	#Rename Similars to the Original's Name + A Unique ID to Avoid Collisions
					ls > ls.txt
				done
				echo "|                                                                        |"
                        	echo " ------------------------------------------------------------------------"
				load
			fi
		fi

        ######------If Filename Does Not Contain Space Char------######	
	else

	        ######------Search Directory for Similar Names------######
		name=$line

                ######------If Name Contains (), Remove It ------######
		if [[ $name == *"("*")"* ]]
                then
                        name=$(echo $name | sed s/"(".")"// | awk -F "." ' { print $1 } ')
                fi
		sims=$(cat ls.txt | grep "$name" | sed s/^"$line"//)
		matches=()

	        ######------If Similars Found, Check if Sizes Match------######
		if [[ $sims == "" ]]
                then
                        :
                else
			original_size=$(ls -l $line | awk ' { print $5 } ')
                        for i in $sims
                        do
                                size=$(ls -l $i | awk ' { print $5 } ')
                                if [[ $size == $original_size ]]
                                then
                                        matches+=( $i )
                                fi
                        done

                        ######------If Any Similars Pass Size Check, Show Them------######
			if [[ ${matches[@]} != "" ]]
			then				
                                echo "------------------------------"
		               	echo "Name is...$name"
				echo "------------------------------"
				echo "                              |"
				echo "                               ----"
				echo "                                   |"
				echo "                                   V"
				#echo $name >> sim-list.txt
				echo "				Similars			       "
				echo " ------------------------------------------------------------------------"
				echo "|                                                                        |"
				for i in ${matches[@]}
				do
					echo $i
					mv $line ORIGINALS/     #Move the original file to a folder     #Move the original file to a folder
					mv $i SIMS/ 	#Move the similar files to a folder     #Move the similar files to a folder
					part1=$(echo $line | awk -F "." ' { print $1 } ')
					part2=$(echo $line | awk -F "." ' { print "."$2 } ')
					mv SIMS/$i SIMS/"$part1(Duplicate-ID-$RANDOM)$part2"	#Rename Similars to the Original's Name + A Unique ID to Avoid Collisions
					ls > ls.txt
				done
				echo "|                                                                        |"
                        	echo " ------------------------------------------------------------------------"
				load
                        fi
                fi


	fi
done

#################################################Check for Commonly Appended Suffixes (such as test.jpg vs test1.jpg)###############################################$

#########---------------------------Run Through Directory Checking for Common Appends---------------------------#########
ls > ls.txt
cat ls.txt | sort -r | while read line;
do
	######------If Filename Contains Space Char------######
	if [[ $line == *"~x~"* ]]
	then
	
	        ######------Isolate Name from Space Char & Check for Appended Character------######
		name=$(echo $line | sed s/"~x~"//)
		part1=$(echo $line | awk -F "." ' { print $1 } ')
		part2=$(echo $line | awk -F "." ' { print "."$2 } ')

		######------Search for Duplicates With Appended Chars------######
		sims=$(grep $part1'[[:digit:]]'$part2 ls.txt)
		matches=()
	        
		######------If None Found, Continue------######
		if [[ $sims == "" ]]
		then
			:

	        ######------If File Found, Check if Sizes Match------######
		else
			original_size=$(ls -l $line | awk ' { print $5 } ')
			for i in $sims
			do
				size=$(ls -l $i | awk ' { print $5 } ')
				if [[ $size == $original_size ]]
				then
					matches+=( $i )		
				fi
			done

	       		######------If Any Pass Size Check, Show Them------######
			if [[ ${matches[@]} != "" ]]
			then				
                                echo "------------------------------"
		               	echo "Name is...$name"
				echo "------------------------------"
				echo "                              |"
				echo "                               ----"
				echo "                                   |"
				echo "                                   V"
				#echo $name >> sim-list.txt
				echo "				Similars			       "
				echo " ------------------------------------------------------------------------"
				echo "|                                                                        |"
				for i in ${matches[@]}
				do
					echo $i
					mv $line ORIGINALS/     #Move the original file to a folder
					mv $i SIMS/ 	#Move the similar files to a folder
					part1=$(echo $line | awk -F "." ' { print $1 } ')
					part2=$(echo $line | awk -F "." ' { print "."$2 } ')
					mv SIMS/$i SIMS/"$part1(Duplicate-ID-$RANDOM)$part2"	#Rename Similars to the Original's Name + A Unique ID to Avoid Collisions
					ls > ls.txt
				done
				echo "|                                                                        |"
                        	echo " ------------------------------------------------------------------------"
				load
			fi
		fi

        ######------If Filename Does Not Contain Space Char------######	
	else

	        ######------Check for Appended Character------######
		name=$line
		part1=$(echo $line | awk -F "." ' { print $1 } ')
                part2=$(echo $line | awk -F "." ' { print "."$2 } ')
		sims=$(grep $part1[[:digit:]]$part2 ls.txt)
		matches=()

	        ######------If Files Found, Check if Sizes Match------######
		if [[ $sims == "" ]]
                then
                        :
                else
			original_size=$(ls -l $line | awk ' { print $5 } ')
                        for i in $sims
                        do
                                size=$(ls -l $i | awk ' { print $5 } ')
                                if [[ $size == $original_size ]]
                                then
                                        matches+=( $i )
                                fi
                        done

                        ######------If Any Pass Size Check, Show Them------######
			if [[ ${matches[@]} != "" ]]
			then				
                                echo "------------------------------"
		               	echo "Name is...$name"
				echo "------------------------------"
				echo "                              |"
				echo "                               ----"
				echo "                                   |"
				echo "                                   V"
				#echo $name >> sim-list.txt
				echo "				Similars			       "
				echo " ------------------------------------------------------------------------"
				echo "|                                                                        |"
				for i in ${matches[@]}
				do
					echo $i
					mv $line ORIGINALS/     #Move the original file to a folder
					mv $i SIMS/ 	#Move the similar files to a folder
					part1=$(echo $line | awk -F "." ' { print $1 } ')
					part2=$(echo $line | awk -F "." ' { print "."$2 } ')
					mv SIMS/$i SIMS/"$part1(Duplicate-ID-$RANDOM)$part2"	#Rename Similars to the Original's Name + A Unique ID to Avoid Collisions
					ls > ls.txt
				done
				echo "|                                                                        |"
                        	echo " ------------------------------------------------------------------------"
				load
                        fi
                fi


	fi
done
ls ORIGINALS > sim-list.txt
load
echo "Completed"

