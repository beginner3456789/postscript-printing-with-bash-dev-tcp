### Gemini AI prompt:

> ***"write a bash script to send a postscript file to a printer 9100/tcp directly"***

### Gemini AI response:

Here is a simple and reliable Bash script to send a PostScript (`.ps`) file directly to a printer via port 9100 (AppSocket/JetDirect protocol) using `nc` (Netcat).

### Bash Script (`send_ps.sh`)

```bash
#!/bin/bash

# Configuration
PRINTER_IP="192.168.1.100"  # Replace with your printer's IP address
PORT=9100

# Check if a filename was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <file.ps>"
    exit 1
fi

FILE="$1"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found!"
    exit 1
fi

echo "Sending '$FILE' to printer at $PRINTER_IP:$PORT..."

# Send the file using netcat
nc -w 5 "$PRINTER_IP" "$PORT" < "$FILE"

if [ $? -eq 0 ]; then
    echo "Successfully sent to printer."
else
    echo "Error: Failed to send file to printer."
    exit 1
fi

```

---

### How to Use It

1. **Save the script:** Save the code above into a file named `send_ps.sh`.
2. **Make it executable:** Give the script execution permissions by running:
```bash
chmod +x send_ps.sh

```


3. **Update the IP:** Open the script and change `192.168.1.100` to your actual network printer's IP address.
4. **Run the script:** Pass your PostScript file as an argument:
```bash
./send_ps.sh document.ps

```



> **Note:** This script relies on `netcat` (`nc`), which is pre-installed on most Linux distributions and macOS. If you get a "command not found" error for `nc`, you can typically install it via your package manager (e.g., `sudo apt install netcat` on Ubuntu/Debian).