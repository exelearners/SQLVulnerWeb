# SQLVulnerWeb
It performs basic tests by injecting common payloads into URL parameters and checking whether database-related errors or unusual responses occur.


Features :-

Sends multiple SQLi payloads to a target URL

Detects SQL error messages from MySQL, PostgreSQL, MSSQL, Oracle

Checks for changes in response length or status code

Logs results to a file

Lightweight and easy to extend

--------------------------------------------------------------------------
Make It Executable :-

sudo chmod +x SQLVulnerWeb.sh


#Usage :-

bash sqli-check.sh "http://example.com/product.php?id=1"


[*] Testing payload: '
[!] Possible SQL Injection vulnerability detected!
Error signature: You have an error in your SQL


Notes & Recommended Improvements

You can enhance this tool by adding:

✔ Multi-threading (GNU Parallel)
✔ POST request scanning
✔ Automatic parameter extraction
✔ Burp Suite–style fuzzing
✔ Output in JSON format
