#!/usr/bin/env bash
I=0
for KEY in `cat fingerprints.csv`; do
    let I=I+1
    >&2 echo "Processing row $I $KEY"
    gpg2 --homedir=./gpghome --keyserver http://keyserver.ubuntu.com --recv-keys $KEY
done
