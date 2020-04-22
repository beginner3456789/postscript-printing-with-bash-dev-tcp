#!/bin/bash
#
#   ++++   driverless bi-directional network postscript printing   ++++
#   bash needs --enable-net-redirections build option
#
# for postscript programs with network postscript printer only
#
# bash escape is \033 or \e or \E or \x1B


if [[ $(file -b "$1") != PostScript\ document\ text ]]; then
  echo "need postscript file" && exit 1
  fi

exec 5<>/dev/tcp/192.168.1.111/9100 || exit 1     # change ip address as needed

# send to printer

{
 echo -e "\E%-12345X@PJL"           # PJL entrance
 echo @PJL ECHO "$(date)"
 echo @PJL ECHO "setting up printer ..."
 echo @PJL COMMENT Change Printer Settings
 echo @PJL SET COPIES = 1           # modify environment settings
 echo @PJL SET MANUALFEED = off
 echo @PJL USTATUSOFF
 echo @PJL USTATUS TIMED = 20
 echo @PJL USTATUS PAGE = on
 echo @PJL ECHO "Starting PostScript Program ..."
 echo @PJL ENTER LANGUAGE = POSTSCRIPT
cat "$1"
 echo -e "\004"                     # ctrl-D for end of file
 echo -e "\e%-12345X@PJL"           # back to PJL
 echo @PJL ECHO "Finished PostScript Program."
 echo @PJL RESET                    # unset modified environment settings
 echo @PJL ECHO BYE.
 echo -e "\033%-12345X"             # PJL universal exit
} >&5                               # send to printer

# now read the printer messages

while read -t 122 -r LINE           # timeout is 122 seconds of silence
do
echo "$LINE"
if [[ "$LINE" =~ ^@PJL\ ECHO\ BYE. ]]; then break; fi   # end
done <&5 || echo "Timeout waiting for printer."

echo "Finished reading printer"

exec 5>&-                           # close
exec 5<&-                           # close both
exit 0
