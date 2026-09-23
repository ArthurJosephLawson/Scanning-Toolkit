#!/bin/bash

DOMAIN="${1:-}"
[[ -z "$DOMAIN" ]] && echo "Usage: bash $0 <domain.com>" && exit 1

echo "Domain & DNS Extractor"
echo "====================="
echo "Target: $DOMAIN"
echo ""

echo "=== A Records ==="
dig +short A "$DOMAIN" 2>/dev/null

echo ""
echo "=== AAAA Records ==="
dig +short AAAA "$DOMAIN" 2>/dev/null

echo ""
echo "=== MX Records ==="
dig +short MX "$DOMAIN" 2>/dev/null

echo ""
echo "=== NS Records ==="
dig +short NS "$DOMAIN" 2>/dev/null

echo ""
echo "=== TXT Records ==="
dig +short TXT "$DOMAIN" 2>/dev/null

echo ""
echo "=== SPF Record ==="
dig TXT "$DOMAIN" 2>/dev/null | grep -i "spf" | sed 's/.*TXT//' | tr -d '"'

echo ""
echo "=== SOA Record ==="
dig +short SOA "$DOMAIN" 2>/dev/null

echo ""
echo "=== CNAME Records ==="
dig +short CNAME "$DOMAIN" 2>/dev/null

echo ""
echo "=== Reverse DNS ==="
IP=$(dig +short A "$DOMAIN" | head -1)
[[ -n "$IP" ]] && host "$IP" 2>/dev/null

echo ""
echo "=== WHOIS Summary ==="
whois "$DOMAIN" 2>/dev/null | awk '/^(Domain|Name Server|Registrar|Creation|Expiry|Status|DNSSEC|Registrant|Admin|tech)/ {print "  " $0}' | head -25

echo ""
echo "=== Common Subdomains ==="
for sub in www mail ftp smtp pop imap blog api cdn admin ns1 ns2 dev test vpn; do
    result=$(dig +short A "$sub.$DOMAIN" 2>/dev/null | head -1)
    [[ -n "$result" ]] && echo "  $sub.$DOMAIN -> $result"
done

echo ""
echo "=== SSL/HTTPS Check ==="
SSL=$(echo | timeout 3 openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -dates -subject 2>/dev/null)
if [[ -n "$SSL" ]]; then
    echo "$SSL" | sed 's/^/  /'
else
    echo "  No SSL detected or connection failed"
fi
