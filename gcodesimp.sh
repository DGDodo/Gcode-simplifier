#!/bin/bash
# ========================================
#         SCRIPT LINUXCNC SIMPLIFY
# ========================================
# feb 2026 DG
#
#;; Adjusted (LinuxCNC) gcode with simplified gcode.
#;; Minimize movements, scriptly adjusted.
#;;
#;; Grab %1, if ampty print help-file and exit
#;; Create a copy of original file (%1_simplified.gcode)
#;; Find Y1, Y2, X1, X2, Z1
#;;
#;; Adjusted lines have the following line before it ;; next removed Y0.0950
#;; Lines which started with 'G1' are set to the next line
#;; Single Y0.0950 lines are commented out
#;;
#;; Same for max: Y14.2500 (example)

# Due to additional special characters (Windows) we have to translate some gcode.
# https://stackoverflow.com/questions/25778587/identify-and-remove-specific-hidden-characters-from-text-file
# Command: tr -cd '\11\12\40-\176' < org.gcode > new.gcode
#

# We make 2 additional /tmp/~_temp files, one with X coordinates ans one with Y coordinates

# INIT
# ====
# Parameters
Pversion=1.0
X1=0   # Lowest X-movement, higher than 0
X2=0   # Highest X-movement
Y1=0   # Lowest Y-movement, higher than 0
Y2=0   # Highest Y-movement
Z1=0   # Any Z movement
LC=0   # Line count
# Get program ID
progid=$$

# check $1 file
if [ "$1" = "" ]; then
  echo "This program needs the '~.gcode' file as parameter."
  exit
fi

# PROGRAM
# =======
# copy original and always translate?
if [ -f $1 ]; then
  str=$(echo $1|cut -d"." -f1)
  tr -cd '\11\12\40-\176' < $1 > "/tmp/"$str"_simplified.gcode"
  str1="/tmp/"$str"_simplified.gcode"
  str2="/tmp/"$str"_Ytemp.txt"
  str3="/tmp/"$str"_Xtemp.txt"
  str21="/tmp/"$str"_Y2temp.txt"
  str31="/tmp/"$str"_X2temp.txt"
fi
# grab nr of lines
LC=$(wc -l $str1|cut -d" " -f1)

#clear
echo
echo "=========================="
echo " LinuxCNC simplify script"
echo "=========================="
echo ""
echo "Original file: '"$1"' has "$LC" lines."
echo "File '"$str1"' has been created and will be adjusted."
echo

count1=0
count2=0
while read -r line; do
  if [ -z "$line" ]; then                 # Count if line is empty
    let count1++
  else                                    # If line is not empty
    if [ ${line:0:1} = ';' ]; then        # If line is a remark / comment
      let count2++
    else                                  # grab X an Y values and put them into temp files
      if [[ ! $line == *"G0"* ]]; then    # Omit gcode G0 lines
        if [[ $line == *"Y"* ]]; then
          echo $line|cut -d"Y" -f2|cut -d" " -f1 >> $str2
        fi
        if [[ $line == *"X"* ]]; then
          echo $line|cut -d"X" -f2|cut -d" " -f1 >> $str3
        fi
      fi
    fi
  fi
done < $str1

echo "File has "$count1" empty lines."
echo "File has "$count2" remark lines."
echo

# Sort files
echo "Sorting files..."
sort -nu $str2 > $str21
sort -nu $str3 > $str31
rm $str2
rm $str3

Y1=$(head -n 1 $str21)
Y2=$(tail -n 1 $str21)
X1=$(head -n 1 $str31)
X2=$(tail -n 1 $str31)

echo "minimum Y value: "$Y1
echo "maximum Y value: "$Y2
echo "minimum X value: "$X1
echo "maximum X value: "$X2

# END
# ===
echo
exit
