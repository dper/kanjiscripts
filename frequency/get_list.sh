#!/bin/sh
#
# Downloads the list of words and frequencies.
# This list was created in 2008 by Michiel Kamermans.
# It has not been updated since.

wget ftp://ftp.edrdg.org/pub/Nihongo/term_aggregates.zip
unzip term_aggregates.zip
rm term_aggregates.zip
