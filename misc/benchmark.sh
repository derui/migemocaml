#!/bin/bash

echo "Benchmark for C/Migemo"

count=100

words=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 2 | head -n $count | sort | uniq)

echo "Word size: 2"
echo "C/Migemo:"
time echo "$words" | cmigemo -d /usr/share/migemo/utf-8/migemo-dict > /dev/null
echo "Migemocaml:"
time echo "$words" | _build/default/bin/main.exe -d /usr/share/migemo/utf-8 > /dev/null

words=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n $count | sort | uniq)

echo "Word size: 4"
echo "C/Migemo:"
time echo "$words" | cmigemo -d /usr/share/migemo/utf-8/migemo-dict > /dev/null
echo "Migemocaml:"
time echo "$words" | _build/default/bin/main.exe -d /usr/share/migemo/utf-8 > /dev/null

words=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n $count | sort | uniq)

echo "Word size: 8"
echo "C/Migemo:"
time echo "$words" | cmigemo -d /usr/share/migemo/utf-8/migemo-dict > /dev/null
echo "Migemocaml:"
time echo "$words" | _build/default/bin/main.exe -d /usr/share/migemo/utf-8 > /dev/null

words=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n $count | sort | uniq)

echo "Word size: 16"
echo "C/Migemo:"
time echo "$words" | cmigemo -d /usr/share/migemo/utf-8/migemo-dict > /dev/null
echo "Migemocaml:"
time echo "$words" | _build/default/bin/main.exe -d /usr/share/migemo/utf-8 > /dev/null
