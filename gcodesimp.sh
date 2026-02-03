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
#;; Same for max: Y14.2500

# Due to additional special characters (Windows) we have to translate some gcode.
# https://stackoverflow.com/questions/25778587/identify-and-remove-specific-hidden-characters-from-text-file
# Command: tr -cd '\11\12\40-\176' < org.gcode > new.gcode
#

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
fi
# grab nr of lines
LC=$(wc -l $str1|cut -d" " -f1)

#clear
echo ""
echo " LinuxCNC simplify script"
echo "=========================="
echo ""
echo "Original file: '"$1"' has "$LC" lines."
echo "File '"$str1"' has been created and will be adjusted."
echo

count1=0
count2=0
while read -r line; do
  if [ -z "$line" ]; then  # Count if line is empty
#    echo "Non-empty line: $line"
    let count1++
  else
    if [ ${line:0:1} = ';' ]; then
      let count2++
    else                 # grab lowest and highest X, Y values
      
    fi
  fi
done < $str1

echo "File has "$count1" empty lines."
echo "File has "$count2" remark lines."
#for /f "tokens=*" %%a in ($str1) do (
#  echo line=%%a
#)

echo ""
echo "minimum Y value: "
echo "maximum Y value: "
echo "minimum X value: "
echo "maximum X value: "

#echo "Has "$LC" lines."


# END
# ===
echo ""
exit
