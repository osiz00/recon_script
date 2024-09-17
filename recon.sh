#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
  echo -e "${YELLOW}Usage: $0 -l listfile -n projectname${NC}"
  exit 1
}

# Parse options
while getopts "l:n:a:t:" opt; do
  case ${opt} in
    l )
      listfile=$OPTARG
      ;;
    n )
      projectname=$OPTARG
      ;;
    a )
      asn=$OPTARG
	;;
    \? )
      usage
      ;;
  esac
done

# Check if both flags are provided
if [ -z "$listfile" ] || [ -z "$projectname" ]; then
  usage
fi

# Create project directory
projectdir="./recon/$projectname"
mkdir -p "$projectdir"

# Initialize subdomains file
subdomains_file="$projectdir/subdomains"
> "$subdomains_file"

# # Subfinder
echo -e "${BLUE}Running Subfinder...${NC}"
subfinder -dL "$listfile" -o "$projectdir/subfinder_output.txt"
cat "$projectdir/subfinder_output.txt" >> "$subdomains_file"
subfinder_count=$(wc -l < "$projectdir/subfinder_output.txt")
echo -e "${GREEN}Subfinder found $subfinder_count subdomains.${NC}"

# Amass
echo -e "${BLUE}Running Amass...${NC}"Document Moved
amass enum -passive -df "$listfile" -o "$projectdir/amass_output.txt"
cat "$projectdir/amass_output.txt" >> "$subdomains_file"
sort -u "$subdomains_file" -o "$subdomains_file"
amass_count=$(grep -Fxvf "$projectdir/subfinder_output.txt" "$projectdir/amass_output.txt" | wc -l)
echo -e "${GREEN}Amass found $amass_count new subdomains.${NC}"
# Amass asn
if [ -n "$asn" ]; then
    echo -e "${BLUE}enumerating subdomains for asn numbers...${NC}"
    IFS=','
    for value in $asn; do
        amass intel -active -asn $value | anew subdomains
    done
    unset IFS
fi
# Httpx
echo -e "${BLUE}Running Httpx to find live hosts...${NC}"
httpx -t 100 -l "$subdomains_file" -o "$projectdir/hosts"
hostnames_count=$(wc -l < "$projectdir/hosts")
echo -e "${GREEN}Httpx found $hostnames_count live hosts.${NC}"
#Subdomain takover
subdominator -l "$projectdir/hosts" | anew subdomains.takeovers
# Waybackurls
echo -e "${BLUE}Running Waybackurls...${NC}"
cat "$projectdir/hosts" | waybackurls > "$projectdir/endpoints.txt"
endpoints_count=$(wc -l < "$projectdir/endpoints.txt")
echo -e "${GREEN}Waybackurls found $endpoints_count endpoints.${NC}"

echo -e "${YELLOW}Recon complete! Results saved in $projectdir.${NC}"

cd "$projectdir"
# Testing for XSS
cat endpoints.txt | grep "=" | gf xss | uro | kxss | anew kxss.txt


