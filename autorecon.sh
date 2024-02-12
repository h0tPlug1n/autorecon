#!/bin/sh
mkdir recon_result_$1
cd recon_result_$1

#Subdomain Enum
subfinder -all -d $1 -o from-subfinder.txt
sublist3r -d $1 -o from-sublister.txt
python3 ~/Desktop/Tools/certsh.py $1
assetfinder -subs-only $1 | tee from-assetfinder.txt

# Cleaning up
cat from-* | anew alldomains.txt
rm from-*

# Curating Subdomains
cat alldomains.txt | httpx -mc 200 -o 200-subdomains.txt
cat alldomains.txt | httpx -mc 404 -o 404-subdomains.txt
cat alldomains.txt | httpx -mc 403 -o 403-subdomains.txt
cat alldomains.txt | httpx -mc 301,302 -o 30X-subdomains.txt
cat alldomains.txt | httpx -fc 200,404,403,301,302 -o httpx-domains.txt

# DNS Enum
httpx -list alldomains.txt -sc -location -fr -ip -cdn -asn -cname -server -td -method -title -vhost -http2 -pipeline -tls-grab -csp-probe -tls-probe -o httpx-report.txt
cat alldomains.txt | dnsx -a -aaaa -cname -ns -txt -srv -ptr -mx -soa -any -axfr -caa -cdn -asn -re -o dnsx-report.txt

# Collecting old URLs
cat alldomains.txt | waybackurls > from-waybackurls.txt

# Crawling
katana -list alldomains.txt -o from-katana.txt

# Network Scans
naabu -list subdomains.txt -nmap-cli 'nmap -sV -sC -A -O -T4 -vv' -o naabu_portscan.txt | tee nmap_scan_detailed.txt
