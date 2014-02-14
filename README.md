onojapanese
===========

A script for playing with onomatopoeic Japanese words.


Dictionary
==========

The `edict.txt` file is under a Creative Commons Attribution-Share Alike 3.0 license.

* <http://www.csse.monash.edu.au/~jwb/edict.html>.
* <http://ftp.monash.edu.au/pub/nihongo/edict.gz>.
* <http://www.edrdg.org/edrdg/licence.html>.


Word Frequencies
================

The word frequency list is public domain and is included with the source.

* <http://ftp.monash.edu.au/pub/nihongo/00INDEX.html>.
* <http://www.bcit-broadcast.com/monash/wordfreq.README>.
* <http://ftp.monash.edu.au/pub/nihongo/wordfreq_ck.gz>.  Retrieved 2014-01-24.


Example Sentences
=================

There are extensive numbers of sample sentences at Tatoeba (<http://tatoeba.org/eng/home>).  The data gets rather large in size, and I do not want to try to keep this repository updated, even if I had the storage space.  This is because these files are the *entire* Tatoeba corpus, not just the Japanese and English sentences we will use in the end.  The files we need are these.

* <http://tatoeba.org/files/downloads/sentences_detailed.csv>.  The sentences themselves.
* <http://tatoeba.org/files/downloads/tags.csv>.  Tags for each sentence.
* <http://tatoeba.org/files/downloads/jpn_indices.csv>.  English and Japanese sentence pair information.

Or if you're lazy, copy and paste this.

    wget http://tatoeba.org/files/downloads/sentences_detailed.csv
    wget http://tatoeba.org/files/downloads/tags.csv
    wget http://tatoeba.org/files/downloads/jpn_indices.csv

The Tatoeba corpus is under a Creative Commons Attribution 2.0 license.

Here is a cautionary disclaimer from Tatoeba (<http://en.wiki.tatoeba.org/articles/show/using-the-tatoeba-corpus>):

````
    Due to the nature of a public collaborative project, this data will never be 100% free of errors.
    Be aware of the following.
        We allow non-native speakers to contribute in languages they are learning.
        We ask our members not to change archaic language to something that currently sounds natural.
        We allow our members to submit book titles and other things you might not consider sentences.
    Translations may not always be accurate, even though the linked sentences are correct sentences.

````
