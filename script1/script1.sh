#!/bin/bash

grep "OK DOWNLOAD"  cdlinux.ftp.log | cut -d'"' -f 2,4 | sort -u | sed "1,\$s#.*/##" | grep "\.iso" > helper.txt

grep "http://cdlinux.pl/download.html" cdlinux.www.log  | grep "\.iso" | cut -d'"' -f 1,2 | sed 's/^[^:]*://' | sed 's/\[[^]]*\]//g' | sort -u| grep -o '[^/]*\.iso\b' >> helper.txt

sort helper.txt | uniq -c
