kanjiscripts
============

Several scripts for playing with Japanese words and sentences.  The goal here is to have some scripts that help us make lists of example Japanese and English sentences so we can in turn take those lists and use them to study Japanese.  If you are taking a course in school, you probably have a textbook and the teacher tells you what to study.  If you are studying on your own, which is particularly common if you live and work in Japan, though, you're on your own for deciding what's best for you.

Choosing your own materials takes time.  However, if you choose what to study on your own, usually you end up being interested in it, which gives you motivation to study and means you're more likely to remember it later.  Also, you can tailor your studies to your life.  For example, are you going to the dentist next month?  Wouldn't it be great to add a hundred dentist or tooth related sentences to your flash card deck?  The scripts here are designed to help you make lists for this kind of situation.


Dictionary
==========

The Japanese dictionary, `edict.txt`, is under a Creative Commons Attribution-Share Alike 3.0 license and is included with the source.

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

There are extensive numbers of sample sentences at Tatoeba (<http://tatoeba.org/eng/home> or <http://tatoeba.org/eng/downloads>).  The data gets rather large in size, and I do not want to try to keep this repository updated.  This is because these files are the *entire* Tatoeba corpus, not just the Japanese and English sentences we will use in the end.  Download and unpack the following files, and you can grab updated versions later as you see fit.

* <http://downloads.tatoeba.org/exports/sentences_detailed_and_links.tar.bz2>.
* <http://downloads.tatoeba.org/exports/tags.tar.bz2>.

If you're lazy, copy and paste this.

    wget http://downloads.tatoeba.org/exports/sentences_detailed_and_links.tar.bz2
    wget http://downloads.tatoeba.org/exports/tags.tar.bz2
    tar xjvf sentences_detailed_and_links.tar.bz2
    tar xjvf tags.tar.bz2

Beware of large files, as shown here.

```Shell
$ date
Sun Aug 17 19:23:45 JST 2014

$ ls -lh *.tar.bz2 *.csv | cut -b 18-
 99M Aug 16 16:00 links.csv
108M Aug 16 16:01 sentences_detailed_and_links.tar.bz2
323M Aug 16 16:00 sentences_detailed.csv
 13M Aug 16 16:00 tags.csv
2.4M Aug 16 21:42 tags.tar.bz2
```

The Tatoeba corpus is under a Creative Commons Attribution 2.0 license.  Here is a cautionary disclaimer from Tatoeba (<http://en.wiki.tatoeba.org/articles/show/using-the-tatoeba-corpus>).

```
Due to the nature of a public collaborative project, this data will never be 100% free of errors.
Be aware of the following.
	We allow non-native speakers to contribute in languages they are learning.
	We ask our members not to change archaic language to something that currently sounds natural.
	We allow our members to submit book titles and other things you might not consider sentences.
Translations may not always be accurate, even though the linked sentences are correct sentences.
```


Scripts
=======

* `make_pairs.rb`. After grabbing the dependencies, run this script to make a *large* file containing English and Japanese sentence pairs. You can search or filter this file for example sentences containing just the words you like.  The resulting file will be called `pairs.txt`.  You only need to run this script once at first, and then later when you grab new versions of the Tatoeba files.  The script can take a long time to run, depending on the speed of your computer.
* `find_ono.rb`. Lists all the onomatopoiec words in edict.
* `list_tags.rb`. Lists tags used in the Tatoeba sentence corpus.  On its own this is not useful, but one can use the output in other scripts to filter based on tags.
* `kana.rb`. A script for generating a phonetic (kana) reading of a Japanese sentence.

These scripts have many dependencies.  To avoid wasting your time with predictable errors, read this entire file and grab dependencies before running them.


Word Frequency Files
====================

The file `ono_words.txt` is a list of all the onomatopoeic words in edict sorted from most to least frequent.  The file `ono_freq.txt` is the same list except with word's frequency included.  Both of these files are generated using `find_ono.rb`.  This should be done rarely, because the output only changes when `edict.txt` does.


Tags
====

The file `tags.txt` is a list of all tags used in Tatoeba.  Over time, the tags used in Tatoeba will change.  We like to filter out sentences that have dangerous-looking tags.  The script `list_tags.rb` lists all of the tags currently used in the Corpus and can be occasionally used to update `tags.txt`.


Kana
====

To generate phonetic (kana) readings of sentences written in standard Japanese (using kanji), we use a program called **Mecab** (<https://code.google.com/p/mecab/>).  The website there is not particularly enlightening.  Regardless, Mecab is a morphological analyzer, which means it looks at a series of symbols and tries to parse them into words that form a sentence.  There are several steps to the installation.  I'm running Debian Sid, and if you're running a similar flavor of Linux, you can follow my directions fairly closely.  If you aren't, this could be tedious.  Sorry!

*Warning: If you miss any steps or do them a little incorrectly, the error messages you see later might not have any relevant information.  Go through this process slowly.*

First, install the necessary packages.  Make sure you install `mecab-ipadic-utf8` and not just the regular `mecab-ipadic`.

    # apt-get install mecab mecab-ipadic-utf8 ruby-ffi ruby-dev ruby-mecab

Install the **natto** gem (<https://bitbucket.org/buruzaemon/natto/wiki/Installation-and-Configuration>).

    # sudo gem install natto

The natto gem depends on a `libmecab.so.2` library, but it doesn't look for the library intelligently.  I check the Debian Sid documentation (<https://packages.debian.org/sid/amd64/libmecab2/filelist>) and see that the library is installed in `/usr/lib/libmecab.so.2`.  To test that everything is working, I do the following.

```Ruby
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


Natto Documentation
===================

There is limited MeCab documentation.  However, the fine people who bring us Natto have worked to fill in the gaps.

Relevant Natto documentation can be found at the following sites.

* <https://bitbucket.org/buruzaemon/natto/src/4972d86c17b67b43ebede3bd83ee3b4937e7c9c1/lib/natto/struct.rb?at=default>
* <https://bitbucket.org/buruzaemon/natto/wiki/Node-Parsing-stat>
* <https://mecab.googlecode.com/svn/trunk/mecab/doc/posid.html>
