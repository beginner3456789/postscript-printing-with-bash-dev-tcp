ChatGPT prompt:

"Write a bash script to send a postscript program directly to a printer without cups or lpr just to printer port 9100 directly"

Response:

You can send PostScript directly to a network printer using Bash and `/dev/tcp`, bypassing CUPS, `lp`, and `lpr` entirely.

The following script opens a TCP connection to the printer on port 9100 (JetDirect / RAW) and streams the PostScript program directly to it.

### `sendps9100.sh`

bash

```bash

#!/usr/bin/env bash
#
# Send PostScript directly to a network printer on TCP port 9100.
# No CUPS, lp, or lpr required.
#
# Usage:
#   ./sendps9100.sh printer_ip file.ps
#   cat file.ps | ./sendps9100.sh printer_ip
#

set -euo pipefail

PORT=9100
TIMEOUT=10

usage() {
    echo "Usage: $0 printer_ip [postscript_file]"
    echo "       cat file.ps | $0 printer_ip"
    exit 1
}

[[ $# -ge 1 ]] || usage

HOST="$1"
shift

# Open TCP connection
exec 3<>"/dev/tcp/${HOST}/${PORT}" || {
    echo "Error: Cannot connect to ${HOST}:${PORT}" >&2
    exit 1
}

# Stream PostScript data
if [[ $# -gt 0 ]]; then
    [[ -r "$1" ]] || {
        echo "Error: Cannot read $1" >&2
        exit 1
    }
    cat -- "$1" >&3
else
    cat >&3
fi

# Close connection to signal end of job
exec 3>&-

echo "PostScript successfully transmitted to ${HOST}:${PORT}"
```

### Usage

Print a PostScript file:

bash

```bash
chmod +x sendps9100.sh
./sendps9100.sh 192.168.1.100 document.ps
```

Pipe PostScript directly:

bash

```bash
cat document.ps | ./sendps9100.sh 192.168.1.100
```

Generate and send PostScript on the fly:

bash

```bash
./sendps9100.sh 192.168.1.100 <<'EOF'
%!PS
/Helvetica findfont 24 scalefont setfont
100 700 moveto
(Hello directly from Bash!) show
showpage
EOF
```

### Alternative: Using `nc` (netcat)

If you prefer netcat, the entire transmission can be done with:

bash

```bash
nc -N 192.168.1.100 9100 < document.ps
```

### Important notes

- The printer must support RAW TCP printing on port 9100.
- The printer must have a native PostScript interpreter (PostScript-compatible printers).
- No printer driver or print spooler is involved.
- Closing the TCP connection signals the end of the print job.
- Successful transmission does not necessarily mean the printer successfully rendered or printed the document.

My recommendation: Use `/dev/tcp` for a pure Bash implementation with no external dependencies beyond standard Unix utilities.
