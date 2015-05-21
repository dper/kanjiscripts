#!/bin/sh
#
# This pulls new sentence data from tatoeba.org.
# The Tatoeba data is updated every week on Saturday.
# Call this script once a week or less frequently.
# Server bandwidth is limited.  Downloading takes a few minutes.

wget http://downloads.tatoeba.org/exports/sentences_detailed.tar.bz2
wget http://downloads.tatoeba.org/exports/links.tar.bz2
wget http://downloads.tatoeba.org/exports/tags.tar.bz2

rm sentences_detailed.csv
rm links.csv
rm tags.csv

tar xjvf sentences_detailed.tar.bz2
tar xjvf links.tar.bz2
tar xjvf tags.tar.bz2

rm sentences_detailed.tar.bz2
rm links.tar.bz2
rm tags.tar.bz2
