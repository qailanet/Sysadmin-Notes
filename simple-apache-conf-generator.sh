#!/bin/bash
HTTPD_MEM=$(ps axo rss,cmd --sort -rss | grep httpd | head --lines 1 | awk '{print $1}');
HTTPD_MEM=$((HTTPD_MEM / 10**3));
service httpd stop;
MEM_TOTAL=$(free -m | head --lines 2 | tail --lines 1 | awk '{print $2}');
MEM_USED=$(free -m | head --lines 2 | tail --lines 1 | awk '{print $3}');
MEM_FREE_POOL="$((MEM_TOTAL - MEM_USED))";
HTTPD_POOL="$((MEM_FREE_POOL*80/100))";
MAX_CLIENT="$((HTTPD_POOL/HTTPD_MEM))";
MIN_SPARE_SRV="$((MAX_CLIENT*15/100))";
MAX_SPARE_SRV="$((MAX_CLIENT*35/100))";
START_SRV=$MIN_SPARE_SRV;
service httpd start;
cat << EOF
Keepalive On
KeepAliveTimeout 5 # Low as possible to keep connection from hanging
Timeout 10 # Max time to wait for response
MaxKeepAliveRequests 100 # Max request for any given page
 
<IfModule prefork.c>
StartServers       $START_SRV
MinSpareServers    $MIN_SPARE_SRV
MaxSpareServers   $MAX_SPARE_SRV
ServerLimit      $MAX_CLIENT
MaxClients	 $MAX_CLIENT
MaxRequestsPerChild  5000 # Up to 10000 if no memory leaks exist
</IfModule>
