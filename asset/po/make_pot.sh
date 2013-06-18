#!/bin/sh

find ../src -type f \( -name "*.as" -o -name "*.mxml" \) > files
xgettext --package-name main --package-version 0.1 --default-domain main --output main.pot --from-code=UTF-8 -L C -f files
rm files
