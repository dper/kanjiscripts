onojapanese
===========

Several scripts for playing with Japanese words and sentences.

* `find_ono.rb`. Lists onomatopoiec words as noted in edict.
* `list_tags.rb`. Lists tags used in the Tatoeba sentence corpus.
* `make_cards.rb`. Makes text for Japanese/English flash cards.

These scripts have many dependencies.  To avoid wasting your time with predictable errors, read this entire file before running them.


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
* <http://tatoeba.org/files/downloads/links.csv>.  Links between matching sentences.

Or if you're lazy, copy and paste this.

    wget http://tatoeba.org/files/downloads/sentences_detailed.csv
    wget http://tatoeba.org/files/downloads/tags.csv
    wget http://tatoeba.org/files/downloads/jpn_indices.csv
    wget http://tatoeba.org/files/downloads/links.csv

Beware of large files, as shown here.

```Shell
$ date
Sat Feb 15 22:07:45 JST 2014

$ ls -lh *.csv | cut -b 18-
 17M Feb  8 19:13 jpn_indices.csv
 88M Feb 15 18:11 links.csv
284M Feb  8 19:14 sentences_detailed.csv
 11M Feb  8 19:15 tags.csv
```

The Tatoeba corpus is under a Creative Commons Attribution 2.0 license.  Here is a cautionary disclaimer from Tatoeba (<http://en.wiki.tatoeba.org/articles/show/using-the-tatoeba-corpus>):

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


Kana
====

To generate phonetic (kana) readings of sentences written in standard Japanese (using kanji), we use a program called **Mecab** (<https://code.google.com/p/mecab/>).  The website there is not particularly enlightening.  Regardless, Mecab is a morphological analyzer, which means it looks at a series of symbols and tries to parse them into words that form a sentence.  There are several steps to the installation.  I'm running Debian Sid, and if you're running a similar flavor of Linux, you can follow my directions fairly closely.  If you aren't, this could be tedious.  Sorry!

First, install the necessary packages.  Be careful not to skip any, because if you're missing some of these, the resulting error messages may not be helpful.

    # apt-get install mecab mecab-ipadic-utf8 ruby-ffi ruby-dev ruby-mecab

Install the **natto** gem (<https://bitbucket.org/buruzaemon/natto/wiki/Installation-and-Configuration>).

    # sudo gem install natto

The natto gem depends on a `libmecab.so.2` library, but it doesn't look for the library intelligently.  I check the Debian Sid documentation (<https://packages.debian.org/sid/amd64/libmecab2/filelist>) and see that the library is installed in `/usr/lib/libmecab.so.2`.  To test that everything is working, I do the following.

```
$ export MECAB_PATH=/usr/lib/libmecab.so.2
$ irb
irb(main):001:0> require 'natto'
=> true
irb(main):002:0> require 'nkf'
=> true
irb(main):003:0> nm = Natto::MeCab.new
=> #<Natto::MeCab:0x0000000149e638 @tagger=#<FFI::Pointer address=0x000000017aae40>, @options={}, @dicts=[#<Natto::DictionaryInfo:0x0000000149e408 type="0", filename="/var/lib/mecab/dic/debian/sys.dic", charset="UTF-8">], @version="0.996">
irb(main):004:0> 
```

If you prefer, you can set the path within Ruby.  This is what the script does.

```
$ irb
irb(main):001:0> ENV['MECAB_PATH']='/usr/lib/libmecab.so.2'
=> "/usr/lib/libmecab.so.2"
irb(main):002:0> require 'natto'
=> true
irb(main):003:0> require 'nkf'
=> true
irb(main):004:0> nm = Natto::MeCab.new
=> #<Natto::MeCab:0x0000000149e638 @tagger=#<FFI::Pointer address=0x000000017aae40>, @options={}, @dicts=[#<Natto::DictionaryInfo:0x0000000149e408 type="0", filename="/var/lib/mecab/dic/debian/sys.dic", charset="UTF-8">], @version="0.996">
irb(main):005:0> 
```
   
If you get an error at any step, something is wrong.  Look at the error message, review the above steps and try to figure it out.  Also make sure you see `charset="UTF-8"` and not `charset="EUC-JP"`.  It is probably a good idea to try a natto test script as well; e.g., <http://tinyurl.com/ptag5wn>.  The way in which kana is generated depends on MeCab.  If you're interested in tweaking the output, see the Japanese documentation here: <http://mecab.googlecode.com/svn/trunk/mecab/doc/index.html#parse>.
