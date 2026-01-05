#!/bin/bash

############################################################
#
#  DeepReconX
#  Aggressive Subdomain Enumeration & Validation Framework
#
#  Author: John Ebinyi Odey
#
#  Disclaimer:
#  This tool is intended for AUTHORIZED security testing,
#  bug bounty programs, and educational purposes ONLY.
#  Unauthorized use against systems you do not own or
#  have explicit permission to test is ILLEGAL.
#
#  The author assumes NO responsibility for misuse.
#
############################################################

########################
# Colors
########################
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

########################
# Banner
########################
banner() {
echo -e "${CYAN}"
echo "██████╗ ███████╗███████╗██████╗ ██████╗ ███████╗ ██████╗ ███╗   ██╗██╗  ██╗"
echo "██╔══██╗██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔═══██╗████╗  ██║╚██╗██╔╝"
echo "██║  ██║█████╗  █████╗  ██████╔╝██████╔╝█████╗  ██║   ██║██╔██╗ ██║ ╚███╔╝ "
echo "██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ ██╔══██╗██╔══╝  ██║   ██║██║╚██╗██║ ██╔██╗ "
echo "██████╔╝███████╗███████╗██║     ██║  ██║███████╗╚██████╔╝██║ ╚████║██╔╝ ██╗"
echo "╚═════╝ ╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝"
echo -e "${RESET}"
echo -e "${YELLOW}DeepReconX | Author: John Ebinyi Odey (Redhound | Hotwrist) | Stodachon${RESET}"
echo -e "${RED}AUTHORIZED USE ONLY${RESET}"
echo ""
}

########################
# Usage
########################
usage() {
    echo -e "${YELLOW}Usage:${RESET} ./deepreconx.sh domain.com [--fast] [--silent]"
    exit 1
}

########################
# Dependency Check (some of you all might forget to install....lols)
########################
deps=(subfinder chaos alterx dnsgen puredns dnsx httpx-toolkit nuclei)

check_deps() {
    echo -e "${BLUE}[*] Checking dependencies...${RESET}"
    for tool in "${deps[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            echo -e "${RED}[!] Missing dependency:${RESET} $tool"
            exit 1
        fi
    done
    echo -e "${GREEN}[✓] All dependencies found${RESET}"
    echo ""
}

########################
# Arguments
########################
FAST=false
SILENT=false

DOMAIN=""

for arg in "$@"; do
    case $arg in
        --fast) FAST=true ;;
        --silent) SILENT=true ;;
        *) DOMAIN="$arg" ;;
    esac
done

[ -z "$DOMAIN" ] && usage

########################
# Output Setup
########################
OUT="output/$DOMAIN"
LOG="$OUT/run.log"
mkdir -p "$OUT"

log() {
    ts=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[$ts] $1" | tee -a "$LOG"
}

run() {
    [ "$SILENT" = false ] && log "$1"
}

########################
# Start
########################
banner
check_deps

run "🔍 Recon started on $DOMAIN"
echo ""

##############################################
# 1. Passive Enumeration (let's go passive...)
##############################################

run "[+] Running subfinder..."
subfinder -d "$DOMAIN" -all -silent | sort -u > "$OUT/subfinder.txt"

run "[+] Running chaos..."
chaos -d "$DOMAIN" -silent | sort -u > "$OUT/chaos.txt"

##############################################
# 2. Combine Results
##############################################

run "[+] Combining subdomains..."
cat "$OUT"/*.txt | sort -u > "$OUT/all_subs.txt"

##############################################
# 3. Permutations
##############################################

run "[+] Running alterx..."
alterx -l "$OUT/all_subs.txt" -p perm4alterx.txt > "$OUT/perms.txt"

alterx -l "$OUT/perms.txt" \
  -p "{word}.{base}" \
  -p "{word}-{base}" \
  -p "api.{word}.{base}" \
  -p "dev.{word}.{base}" \
  -p "test.{word}.{base}" \
  -p "stage.{word}.{base}" \
  -p "internal.{word}.{base}" \
  -p "vpn.{word}.{base}" \
  -p "corp.{word}.{base}" \
  -p "v1.{word}.{base}" \
  -p "v2.{word}.{base}" \
  -o "$OUT/alterx_candidates.txt"

run "[+] Running dnsgen..."
dnsgen "$OUT/all_subs.txt" -w perm4alterx.txt > "$OUT/dnsgen.txt"

cat "$OUT/alterx_candidates.txt" "$OUT/dnsgen.txt" | sort -u > "$OUT/mutations.txt"

##############################################
# 4. DNS Resolution
##############################################

run "[+] Resolving with puredns..."
cat "$OUT/all_subs.txt" "$OUT/mutations.txt" | sort -u > "$OUT/final_candidates.txt"
puredns resolve "$OUT/final_candidates.txt" -r resolvers.txt -w "$OUT/resolved.txt"

##############################################
# 5. DNS Info
##############################################

run "[+] Running dnsx..."
dnsx -l "$OUT/resolved.txt" -resp -a -cname -silent > "$OUT/dns_info.txt"

##############################################
# 6. HTTP Probing
##############################################

run "[+] Running httpx..."
httpx-toolkit -l "$OUT/resolved.txt" -probe -status-code -location -cl \
    | grep -E "200|301|302|401|403|404|500" \
    > "$OUT/httpx_live.txt"

##############################################
# 7. Nuclei
##############################################

if [ "$FAST" = false ]; then
    run "[+] Running nuclei (critical, high)..."
    nuclei -l "$OUT/httpx_live.txt" -severity critical,high -silent \
        > "$OUT/nuclei_findings.txt"
else
    run "[*] Fast mode enabled — skipping nuclei"
fi

##############################################
# Done
##############################################

echo ""
echo -e "${GREEN}🎉 RECON COMPLETED! CONGRATULATIONS HACKER!${RESET}"
echo -e "${CYAN}Results saved in:${RESET} $OUT"
echo ""

