kanjiscripts
============

Several scripts for playing with Japanese words and sentences.  The goal here is to have some scripts that help us make lists of example Japanese and English sentences so we can in turn take those lists and use them to study Japanese.  If you are taking a course in school, you probably have a textbook and the teacher tells you what to study.  If you are studying on your own, which is particularly common if you live and work in Japan, though, you're on your own for deciding what's best for you.

Choosing your own materials takes time.  However, if you choose what to study on your own, usually you end up being interested in it, which gives you motivation to study and means you're more likely to remember it later.  Also, you can tailor your studies to your life.  For example, are you going to the dentist next month?  Wouldn't it be great to add a hundred dentist or tooth related sentences to your flash card deck?  The scripts here are designed to help you make lists for this kind of situation.


Dictionary
==========

The Japanese dictionary, `edict.txt`, is under a Creative Commons Attribution-Share Alike 3.0 license and is included with the source.

* <http://www.edrdg.org/jmdict/edict.html>.
* <ftp://ftp.edrdg.org/pub/Nihongo/edict.gz>.
* <http://www.edrdg.org/edrdg/licence.html>.


Example Sentences
=================

There are extensive numbers of sample sentences at [Tatoeba](http://tatoeba.org/eng/downloads).  The data gets rather large in size, and I do not want to try to keep this repository updated.  This is because these files are the *entire* Tatoeba corpus, not just the Japanese and English sentences we will use in the end.  The Tatoeba corpus is under a Creative Commons Attribution 2.0 license.  Here is a cautionary [disclaimer](http://en.wiki.tatoeba.org/articles/show/using-the-tatoeba-corpus).

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

There are many different scripts.  See the comments at the top of each script for more information.

* `sentences/find_words_in_file.rb`. This script finds sentence pairs for target words.  It looks for words listed in `target_words.txt`, with one word per line, and finds up to three sentences for each of those words.  The results are placed in `target_sentences.txt`.  I use these sentences in flashcards, and long Japanese sentences are bad for flashcard use.  There is a maximum character length filter in `find_pairs.rb` that can be adjusted to your needs.
* `sentences/make_pairs.rb`. After grabbing the dependencies, run this script to make a *large* file containing English and Japanese sentence pairs. You can search or filter this file for example sentences containing just the words you like.  The resulting file will be called `pairs.txt`.  You only need to run this script once at first, and then later when you grab new versions of the Tatoeba files.  The script can take a long time to run, depending on the speed of your computer.
* `frequency/frequencies.rb`.  Lists words by frequency of use filtered by part of speech.
* `onomatopeia/find_ono.rb`. Lists all the onomatopoiec words in edict.
* `tags/list_tags.rb`. Lists tags used in the Tatoeba sentence corpus.  On its own this is not useful, but one can use the output in other scripts to filter based on tags.

These scripts have many dependencies.  To avoid wasting your time with predictable errors, be sure to download the dependencies before running them.


Kana
====

To generate phonetic (kana) readings of sentences written in standard Japanese (using kanji), we use a program called [Mecab](https://code.google.com/p/mecab/).  The website there is not particularly enlightening.  Regardless, Mecab is a morphological analyzer, which means it looks at a series of symbols and tries to parse them into words that form a sentence.  There are several steps to the installation.  I'm running Debian Sid, and if you're running a similar flavor of Linux, you can follow my directions fairly closely.  If you aren't, this could be tedious.  Sorry!

*Warning: If you miss any steps or do them a little incorrectly, the error messages you see later might not have any relevant information.  Go through this process slowly.*

First, install the necessary packages.  Make sure you install `mecab-ipadic-utf8` and not just the regular `mecab-ipadic`.

    # apt install mecab mecab-ipadic-utf8 ruby-ffi ruby-dev ruby-mecab

Install the [natto](https://bitbucket.org/buruzaemon/natto/wiki/Installation-and-Configuration) gem.

    # gem install natto

The natto gem depends on a `libmecab.so.2` library, but it doesn't look for the library intelligently.  I check the Debian Sid [documentation](https://packages.debian.org/sid/amd64/libmecab2/filelist) and see that the library is installed in `/usr/lib/x86_64-linux-gnu/libmecab.so.2`.  To test that everything is working, I do the following.

```Ruby
irb(main):001:0> ENV['MECAB_PATH']='/usr/lib/x86_64-linux-gnu/libmecab.so.2'
=> "/usr/lib/libmecab.so.2"
irb(main):002:0> require 'natto'
=> true
irb(main):003:0> require 'nkf'
=> true
irb(main):004:0> nm = Natto::MeCab.new
=> #<Natto::MeCab:0x0000000149e638 @tagger=#<FFI::Pointer address=0x000000017aae40>, @options={}, @dicts=[#<Natto::DictionaryInfo:0x0000000149e408 type="0", filename="/var/lib/mecab/dic/debian/sys.dic", charset="UTF-8">], @version="0.996">
irb(main):005:0> 
```

If you can't find `libmecab.so.2`, the following command should help do so.

    # find / -name libmecab.so*

If you get an error at any step, something is wrong.  Look at the error message, review the above steps and try to figure it out.  Also make sure you see `charset="UTF-8"` and not `charset="EUC-JP"`.  It is probably a good idea to try a natto test script as well; e.g., <http://tinyurl.com/ptag5wn>.  The way in which kana is generated depends on MeCab.  If you're interested in tweaking the output, see the [Japanese documentation](http://mecab.googlecode.com/svn/trunk/mecab/doc/index.html#parse).


Single Characters
=================

Suppose you're trying to learn some kanji, as opposed to words.  A good way to learn the kanji is to find some sentences that contain them.  You might have a text file that has one hundred kanji all on one line.  To use `find_words_in_file.rb`, you need a file with one word (in this case, one character) per line.  The command `fold` should do the trick.  Suppose your starting file is called `list.txt`.

    fold -b3 list.txt > list.2.txt

The above command will output the same kanji, with one per line.  Rename `list.2.txt` to `target_words.txt`, run `find_words_in_file.rb`, and you're done.


Natto Documentation
===================

There is limited MeCab documentation.  However, the fine people who bring us Natto have worked to fill in the gaps.  Relevant Natto documentation can be found at the following sites.

* <https://bitbucket.org/buruzaemon/natto/src/4972d86c17b67b43ebede3bd83ee3b4937e7c9c1/lib/natto/struct.rb?at=default>
* <https://bitbucket.org/buruzaemon/natto/wiki/Node-Parsing-stat>
* <https://mecab.googlecode.com/svn/trunk/mecab/doc/posid.html>


Source
======

* GitHub: <https://github.com/dper/kanjiscripts/>


Contact
=======

If you want to contact the author, here are some ways.

* <https://twitter.com/dpp0>
* <https://dperkins.org/tag/contact.html>
