#!/bin/sh
# ========================================
#         SCRIPT LINUXCNC SIMPLIFY
# ========================================
# feb 2026
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

# Parameters
X1=0
X2=0
Y1=0
Y2=0
Z1=0
LC=0
# Get program ID
progid=$$

# INIT
if %1 ="" then 
  echo "This program needs the .gcode file as parameter."
  exit
fi

# Program
if [ -f %1 ] then
  cp %1 /tmp/%1_simplified.gcode
fi


