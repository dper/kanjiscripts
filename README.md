onojapanese
===========

A script for playing with Japanese words and sentences.  There are several scripts.

* `find_ono.rb`. Lists onomatopoiec words as noted in edict.
* `list_tags.rb`. Lists tags used in the Tatoeba sentence corpus.
* `make_cards.rb`. Makes text for Japanese/English flash cards.


Dictionary
==========

The Japanese dictionary, `edict.txt`, is under a Creative Commons Attribution-Share Alike 3.0 license.

* <http://www.csse.monash.edu.au/~jwb/edict.html>.
* <http://ftp.monash.edu.au/pub/nihongo/edict.gz>.  Retrieved 2014-01-24.
* <http://www.edrdg.org/edrdg/licence.html>.


Word Frequencies
================

The word frequency list, `wordfreq_ck.txt`, is public domain and is included with the source.

* <http://ftp.monash.edu.au/pub/nihongo/00INDEX.html>.
* <http://www.bcit-broadcast.com/monash/wordfreq.README>.
* <http://ftp.monash.edu.au/pub/nihongo/wordfreq_ck.gz>.  Retrieved 2014-01-24.


Example Sentences
=================

There are extensive numbers of sample sentences at Tatoeba (<http://tatoeba.org/eng/home> or <http://tatoeba.org/eng/downloads>).  The data gets rather large in size, and I do not want to try to keep this repository updated.  This is because these files are the *entire* Tatoeba corpus, not just the Japanese and English sentences we will use in the end.  Download the following files, and you can grab updated versions later as you see fit.

* <http://tatoeba.org/files/downloads/sentences_detailed.csv>.  The sentences themselves.
* <http://tatoeba.org/files/downloads/tags.csv>.  Tags for each sentence.
* <http://tatoeba.org/files/downloads/jpn_indices.csv>.  English and Japanese sentence pair information.

Or if you're lazy, copy and paste this.

    wget http://tatoeba.org/files/downloads/sentences_detailed.csv
    wget http://tatoeba.org/files/downloads/tags.csv
    wget http://tatoeba.org/files/downloads/jpn_indices.csv

Beware of large files, as shown here.

```Shell
$ date
Fri Feb 14 22:04:26 JST 2014

$ ls -lh *.csv | cut -b 18-
 17M Feb  8 19:13 jpn_indices.csv
284M Feb  8 19:14 sentences_detailed.csv
 11M Feb  8 19:15 tags.csv
```

The Tatoeba corpus is under a Creative Commons Attribution 2.0 license.

Here is a cautionary disclaimer from Tatoeba (<http://en.wiki.tatoeba.org/articles/show/using-the-tatoeba-corpus>):

```
Due to the nature of a public collaborative project, this data will never be 100% free of errors.
Be aware of the following.
	We allow non-native speakers to contribute in languages they are learning.
	We ask our members not to change archaic language to something that currently sounds natural.
	We allow our members to submit book titles and other things you might not consider sentences.
Translations may not always be accurate, even though the linked sentences are correct sentences.
```


Word Frequency Files
====================

* `ono_words.txt` is a list of all the onomatopoeic words in edict sorted from most to least frequent.
* `ono_freq.txt` is the same list except that the word's frequency is included along with the word.

Both `ono_words.txt` and `ono_freq.txt` can be generated using `find_ono.rb`.  This need only be done rarely, because relevant updates to edict are infrequent.


Tags
====

* `tags.txt` is a list of all tags used in Tatoeba.

Over time, it is possible that Tatoeba will expand to use more tags.  We like to filter out sentences that have dangerous-looking tags.  The script `list_tags.rb` lists all of the tags currently used in the Corpus and can be occasionally used to update `tags.txt`.
