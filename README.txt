Scanning Toolkit
================

A collection of bash scanning/recon scripts.

Scripts
-------

dnsinfo.sh <domain.com>
    DNS records (A, AAAA, MX, NS, TXT, SPF, SOA, CNAME), reverse DNS,
    WHOIS summary, common subdomain check, SSL certificate info.

filescan.sh [path]
    File metadata, type/extension mismatch check, embedded files (binwalk),
    strings, image/PDF/document metadata, steganography signatures.
    Defaults to current directory.

folderscan.sh [directory]
    Directory stats and formatted listing with totals. Defaults to ".".

localnetwork.sh
    Ping-scan your local /24 with nmap and list hosts that are up.
    Run with sudo for MAC/vendor info.

port_scan.sh -IP <target_ip>
    Scan ports 1-1024 on a target and list open ports.

Requirements
------------

    bash, dig, host, whois, file, strings, stat
    Optional: nmap, exiftool, binwalk, pdfinfo

Usage
-----

    bash dnsinfo.sh example.com
    bash filescan.sh suspicious.png
    bash folderscan.sh /var/log
    sudo bash localnetwork.sh
    bash port_scan.sh -IP 192.168.1.1

Only scan systems you own or have permission to test.
