# postscript-printing-with-bash-dev-tcp

Simple driverless postscript printing with bash /dev/tcp networking.

This script provides bi-directional communications with a network printer.

bash needs the --enable-net-redirections compile time option.

Be sure to change the example ip address to match your own printer address.

The example PJL can easily be changed as desired.

The script is set to timeout after 122 seconds and can be easily changed.

The script will finish early if the BYE matches. That could depend on printer cr/lf issues.

Use with "./print.sh test.ps" or install to /usr/local/bin and "print.sh test.ps"

