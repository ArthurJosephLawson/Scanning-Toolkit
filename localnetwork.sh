#!/bin/bash

SUBNET=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)/24

echo "Local Network Scanner"
echo "====================="
echo "Scanning: $SUBNET"
echo ""

TMP=$(mktemp)
nmap -sn -PR "$SUBNET" -oN "$TMP" >/dev/null 2>&1

echo "IP              Hostname                Status"
echo "--------------- ---------------------- ------"

awk '
/^Nmap scan report/ {
    line = $0
    sub(/^Nmap scan report for /, "", line)
    sub(/\)$/, "", line)
    if (index(line, "(") > 0) {
        n = split(line, parts, "(")
        host = parts[1]
        ip = parts[2]
    } else {
        ip = line
        host = "(no hostname)"
    }
}
/Host is up/ {
    printf "%-15s  %-22s  %s\n", ip, host, "up"
}
' "$TMP"

echo ""
echo "Hosts up: $(grep -c "Host is up" "$TMP")"
echo ""
echo "Run with sudo for MAC/vendor info"
rm -f "$TMP"
