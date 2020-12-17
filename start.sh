#!/bin/busybox sh
set -e
/usr/local/bin/bedrock -fork $BEDROCK_PARAMS
busybox syslogd -Sn