#!/bin/sh

find . -type f -name "*.po" > po

sed -i -e 's/\.po//g' po
locales=`cat po`
rm po

out=../locale
mkdir -p $out

for locale in $locales; do
    echo "Processing "$locale".po ..."
    mkdir -p $out/$locale/LC_MESSAGES
    msgfmt --check --verbose --output-file $out/$locale/LC_MESSAGES/main.mo $locale.po
done
