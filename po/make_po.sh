#!/bin/sh

pot=`find . | grep -i \.pot$`
msginit --no-translator --locale $1 --output-file $1.po --input $pot

#echo "Missing locale: usage ./make_po.sh <locale>"
