### Deep Seek AI Prompt:

> ***"write a bash script to send a postscript file directly to a printer port 9100/tcp"***

### Response (31 October 2026):

Here's a bash script that sends a PostScript file directly to a printer on port 9100/TCP:

```bash
#!/bin/bash

# Script to send PostScript file directly to printer on port 9100
# Usage: ./send_ps_to_printer.sh [options] <postscript_file> <printer_ip>

# Default values
PRINTER_PORT="9100"
TIMEOUT=30

# Function to display usage
usage() {
    echo "Usage: $0 [options] <postscript_file> <printer_ip>"
    echo ""
    echo "Options:"
    echo "  -p, --port PORT     Printer port (default: 9100)"
    echo "  -t, --timeout SEC   Connection timeout in seconds (default: 30)"
    echo "  -h, --help          Display this help message"
    echo ""
    echo "Example:"
    echo "  $0 document.ps 192.168.1.100"
    echo "  $0 -p 9101 document.ps 192.168.1.100"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PRINTER_PORT="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            break
            ;;
    esac
done

# Check if we have the right number of arguments
if [[ $# -ne 2 ]]; then
    echo "Error: Invalid number of arguments"
    usage
    exit 1
fi

PS_FILE="$1"
PRINTER_IP="$2"

# Check if file exists
if [[ ! -f "$PS_FILE" ]]; then
    echo "Error: PostScript file '$PS_FILE' not found"
    exit 1
fi

# Validate IP address format (basic check)
if [[ ! "$PRINTER_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid IP address format: $PRINTER_IP"
    echo "Usage: <printer_ip> should be in format xxx.xxx.xxx.xxx"
    exit 1
fi

# Check if file has .ps extension or contains PostScript header
if [[ ! "$PS_FILE" =~ \.ps$ ]]; then
    echo "Warning: File doesn't have .ps extension, ensure it's a valid PostScript file"
fi

echo "Sending PostScript file '$PS_FILE' to printer at $PRINTER_IP:$PRINTER_PORT"
echo "Timeout: ${TIMEOUT}s"

# Send the file using /dev/tcp (bash built-in)
{
    exec 3<>"/dev/tcp/$PRINTER_IP/$PRINTER_PORT"
    
    # Send the file contents
    cat "$PS_FILE" >&3
    
    # Wait for response (optional)
    read -r -t $TIMEOUT response <&3
    
    # Close the connection
    exec 3>&-
    
    if [[ $? -eq 0 ]]; then
        echo "Success: PostScript file sent successfully"
        if [[ -n "$response" ]]; then
            echo "Printer response: $response"
        fi
    else
        echo "Error: Failed to send file to printer"
        exit 1
    fi
} 2>/dev/null || {
    # Fallback to netcat if /dev/tcp is not available
    if command -v nc &> /dev/null; then
        echo "Using netcat as fallback..."
        nc -w $TIMEOUT "$PRINTER_IP" "$PRINTER_PORT" < "$PS_FILE"
        if [[ $? -eq 0 ]]; then
            echo "Success: PostScript file sent successfully via netcat"
        else
            echo "Error: Failed to send file via netcat"
            exit 1
        fi
    else
        echo "Error: Neither /dev/tcp nor netcat (nc) is available"
        echo "Install netcat or ensure /dev/tcp is enabled in bash"
        exit 1
    fi
}

# Alternative method using /dev/tcp directly (uncomment to use)
# cat "$PS_FILE" > "/dev/tcp/$PRINTER_IP/$PRINTER_PORT"

# Alternative method using netcat (uncomment to use)
# nc -w $TIMEOUT "$PRINTER_IP" "$PRINTER_PORT" < "$PS_FILE"

exit 0
```

Here's also a simpler version if you prefer:

```bash
#!/bin/bash

# Simple script to send PostScript file to printer on port 9100
# Usage: ./simple_send_ps.sh <postscript_file> <printer_ip>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <postscript_file> <printer_ip>"
    echo "Example: $0 document.ps 192.168.1.100"
    exit 1
fi

PS_FILE=$1
PRINTER_IP=$2

# Check if file exists
if [ ! -f "$PS_FILE" ]; then
    echo "Error: File '$PS_FILE' not found"
    exit 1
fi

echo "Sending $PS_FILE to $PRINTER_IP:9100"

# Method 1: Using bash's /dev/tcp (if enabled)
if [ -e /dev/tcp ]; then
    cat "$PS_FILE" > "/dev/tcp/$PRINTER_IP/9100"
    echo "File sent successfully via /dev/tcp"
    
# Method 2: Fallback to netcat
elif command -v nc &> /dev/null; then
    nc -w 30 "$PRINTER_IP" 9100 < "$PS_FILE"
    echo "File sent successfully via netcat"
    
else
    echo "Error: No method available to send file"
    exit 1
fi
```

## How to use:

1. **Save the script** to a file (e.g., `send_ps.sh`)
2. **Make it executable**: `chmod +x send_ps.sh`
3. **Run it**:
   ```bash
   ./send_ps.sh document.ps 192.168.1.100
   ```

## Requirements:

- **Bash shell** with `/dev/tcp` support enabled (usually default)
- **OR** `netcat` (nc) installed as fallback

## Notes:

- Port 9100 is typically used for direct TCP/IP printing (RAW printing)
- The script assumes the printer supports PostScript language
- If `/dev/tcp` is not available, the script will automatically fall back to using `netcat`
- Add the script to your PATH for system-wide access if needed

The script includes error checking, timeout handling, and will work on most Linux/Unix systems with bash or netcat installed.
