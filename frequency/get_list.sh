#!/bin/sh
#
# Downloads the list of words and frequencies.
# This list was created in 2008 by Michiel Kamermans.
# It has not been updated since.
#
# ftp://ftp.edrdg.org/pub/Nihongo/00INDEX.html
# http://pomax.nihongoresources.com/index.php?entry=1222520260

wget ftp://ftp.edrdg.org/pub/Nihongo/term_aggregates.zip
unzip term_aggregates.zip
rm term_aggregates.zip
