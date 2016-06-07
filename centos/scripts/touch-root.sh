#!/usr/bin/env bash
#
# Test script to create a file at the root of the file system

cat <<EOF > /touched-root.txt
This is a test
EOF

for n in 0 1 2 3 4 5
do
    echo "BASH_VERSINFO[$n] = ${BASH_VERSINFO[$n]}" >> /touched-root.txt
done
