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

# TO DO: remove end-lines (and start-lines) without Z movement

# Due to additional special characters (Windows) we have to translate some gcode.
# https://stackoverflow.com/questions/25778587/identify-and-remove-specific-hidden-characters-from-text-file
# Command: tr -cd '\11\12\40-\176' < org.gcode > new.gcode
# Conversion is done on all loaded gcode.

# We make 2 additional /tmp/~_temp files, one with X ands one with Y coordinates.
# Files also used for conversion.

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
# copy and convert original gcode
if [ -f $1 ]; then
  str=$(echo $1|cut -d"." -f1)					# Filename till first point in filename
  str1="/tmp/"$str"_simplified.gcode"				# New simplified filename
  str2="/tmp/"$str"_Ytemp.txt"					# Temporarly Y values 1 filename
  str3="/tmp/"$str"_Xtemp.txt"					# Temporarly X values 1 filename
  str21="/tmp/"$str"_Y2temp.txt"				# As above nr 2
  str31="/tmp/"$str"_X2temp.txt"				# As above nr 2
# Remove temporarly files if exist
  if [ -f $str1 ]; then rm $str1; fi
  if [ -f $str2 ]; then rm $str2; fi
  if [ -f $str3 ]; then rm $str3; fi
  if [ -f $str21 ]; then rm $str21; fi
  if [ -f $str31 ]; then rm $str31; fi
# Covert original to /tmp
  tr -cd '\11\12\40-\176' < $1 > $str1
fi

# grab nr of lines
LC=$(wc -l $str1|cut -d" " -f1)

#clear
echo ""
echo "=========================="
echo " LinuxCNC simplify script"
echo "=========================="
echo ""
echo "Original file: '"$1"' has "$LC" lines."
echo "File '"$str1"' has been created and will be adjusted..."
echo "Analyzing ..."
echo

count1=0  # Empty lines
count2=0  # remarks / comments

while read -r line; do
  if [ -z "$line" ]; then                     # Count if line is empty
    let count1++
  else                                        # If line is not empty
    if [ ${line:0:1} = ';' ]; then            # Count if line is a remark / comment
      let count2++
    else                                      # Grab X an Y values and put them into temp files
      if [[ ! $line == *"G0"* ]]; then        # Omit gcode G0 lines    || [[ ! $line == *"G3"* ]]
        if [[ ! $line == *"G3"* ]]; then      # Omit gcode G3 lines
          if [[ $line == *"Y"* ]]; then
            echo $line|cut -d"Y" -f2|cut -d" " -f1 >> $str2
          fi
          if [[ $line == *"X"* ]]; then
            echo $line|cut -d"X" -f2|cut -d" " -f1 >> $str3
          fi
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

echo
echo "minimum Y value: "$Y1
echo "maximum Y value: "$Y2
echo "minimum X value: "$X1
echo "maximum X value: "$X2

echo
echo  "Converting..."

# First replace run: replace 'G1 Y<lowest> Z0.0000' with 'G1 Z0.0000 ;; removed Y<lowest>'
# And the same for higest Y value
string1="G1 Y"$Y1" Z0.0000"
string2="G1 Z0.0000 ;; removed Y"$Y1
string3="G1 Y"$Y2" Z0.0000"
string4="G1 Z0.0000 ;; removed Y"$Y2
string5=" Y"$Y1
string6=";; Y"$Y1
string7=" Y"$Y2
string8=";; Y"$Y2
string9=" Y"$Y1" Z0.0000"
string10=" Z0.0000 ;; removed Y"$Y1
string11=" Y"$Y2" Z0.0000"
string12=" Z0.0000 ;; removed Y"$Y2

while IFS='' read -r line; do
  if [ "$line" = "$string1" ]; then echo "${line//$string1/$string2}"
    else if [ "$line" = "$string3" ]; then echo "${line//$string3/$string4}"
      else if [ "$line" = "$string5" ]; then echo "${line//$string5/$string6}"
        else if [ "$line" = "$string7" ]; then echo "${line//$string7/$string8}"
          else if [ "$line" = "$string9" ]; then echo "${line//$string9/$string10}"
            else if [ "$line" = "$string11" ]; then echo "${line//$string11/$string12}"
              else echo "$line"
            fi
          fi
        fi
      fi
    fi
  fi
done < $str1 > $str2

# Next find 'G1 ' rules for which the 'G1 ' has to be on the next line before ruling them out.
string13="G1 Y"$Y1 # minimum Y value
string14="G1 Y"$Y2 # maximum Y value
while IFS='' read -r line; do
  if [ "$line" = "$string13" ]; then
    echo ";; "$line
    read -r line
    echo "G1 "$line
    else if [ "$line" = "$string14" ]; then
      echo ";; "$line
      read -r line
      echo "G1 "$line
      else echo "$line"
    fi
  fi
done < $str2 > $str3

# TO DO: remove end-lines without Z movement

# Add (new) header to gcode
cat << EOF > $str2
;; ==========================
;;  LinuxCNC simplify script
;; ==========================
;; DG feb 2026
;; Script used to simplify LinuxCNC movements of gcode
;; generated with the internal 'image to G-code' function.
;; Scan Pattern = Columns   Scan Direction = Alternating
;; https://github.com/DGDodo/Gcode-simplifier
;;
EOF
cat $str3 >> $str2

# Copy end file to original location
cp $str2 $str"_simplified.gcode"

# remove used temp files
if [ -f $str1 ]; then rm $str1; fi
if [ -f $str2 ]; then rm $str2; fi
if [ -f $str3 ]; then rm $str3; fi
if [ -f $str21 ]; then rm $str21; fi
if [ -f $str31 ]; then rm $str31; fi

# END
# ===
echo "Done."
echo
exit
