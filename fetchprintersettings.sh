#!/bin/bash

# retrieve printer settings using PJL
#
# requires bash built with --enable-net-redirections

exec 5<>/dev/tcp/192.168.1.111/9100   # change ip address as needed

{
echo -e "\033%-12345X@PJL"
echo @PJL ECHO Begin Info Variables
echo @PJL INFO VARIABLES
echo @PJL ECHO End Info Variables
echo -e "\033%-12345X"
} >&5

( trap exit SIGINT; cat <&5 )       # Ctrl-C when finished

exec 5<&-
exec 5>&-

echo finished
exit 0

#EOF

