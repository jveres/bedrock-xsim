#!/bin/busybox sh
#busybox --install -s /bin
#mkdir -p /db; touch /db/bedrock.db
/usr/local/bin/bedrock -fork $BEDROCK_PARAMS
busybox syslogd -Sn