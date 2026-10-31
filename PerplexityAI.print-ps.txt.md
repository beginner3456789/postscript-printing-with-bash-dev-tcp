### Perplexity AI Prompt:

> ***"write bash script to send postscript file to printer port 9100 with tcp"***

### Perplexity AI Response (31 October 2026):

Use Bash’s **`/dev/tcp`** redirection to send the PostScript file directly to the printer on TCP port 9100, without needing `nc` or a print spooler. The printer must support PostScript and have raw TCP printing enabled. [linuxvox](https://linuxvox.com/blog/linux-print-directly-to-network-printer-that-is-not-installed/)

Save this as `print-ps.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    printf 'Usage: %s PRINTER_HOST FILE.ps\n' "$0" >&2
    exit 1
fi

printer=$1
file=$2
port=9100

if [[ ! -f "$file" || ! -r "$file" ]]; then
    printf 'Error: not a readable file: %s\n' "$file" >&2
    exit 1
fi

# Connect, stream the file unchanged, and close the connection.
if cat -- "$file" >"/dev/tcp/$printer/$port"; then
    printf 'File sent to %s:%s\n' "$printer" "$port"
else
    printf 'Error: failed to send file to %s:%s\n' "$printer" "$port" >&2
    exit 1
fi
```

## Usage

```bash
chmod +x print-ps.sh
./print-ps.sh 192.168.1.50 document.ps
```

For a one-off transfer, the equivalent is:

```bash
bash -c 'cat -- "$1" >"/dev/tcp/$2/9100"' _ document.ps 192.168.1.50
```

## Notes

- Run this with Bash, not `sh`. `/dev/tcp` is a Bash redirection feature and requires a Bash build with network redirections enabled. [stackoverflow](https://stackoverflow.com/questions/60578368/postscript-printing-with-netcat)
- This sends the file as-is; it does not convert it to PostScript or add printer-specific commands. The printer must understand the file’s format. [linuxvox](https://linuxvox.com/blog/linux-print-directly-to-network-printer-that-is-not-installed/)
- “File sent” means the data transfer completed—not that the printer confirmed successful printing. Raw port 9100 connections can return printer messages, but this script does not read them. [ujr.github](https://ujr.github.io/pracc/doc/Network.html)
