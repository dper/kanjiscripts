#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# kana.rb
#
# == USAGE
# ./kana.rb
#
# == DESCRIPTION
# A script that makes phonetic readings of Japanese sentences.
#
# == AUTHOR
# Douglas P Perkins - https://dperkins.org - https://microca.st/dper

ENV['MECAB_PATH']='/usr/lib/libmecab.so.2'
require 'natto'
require 'nkf'

# A parsed sentence produces tokens, and each token has a character type.
# Reference: https://bitbucket.org/buruzaemon/natto/wiki/Node-Parsing-char_type
# Reference: http://d.hatena.ne.jp/NE555/20120107
CHAR_TYPE_DEFAULT = 0
CHAR_TYPE_SPACE = 1
CHAR_TYPE_KANJI = 2
CHAR_TYPE_SYMBOL = 3
CHAR_TYPE_NUMERIC = 4
CHAR_TYPE_ALPHA = 5
CHAR_TYPE_HIRAGANA = 6
CHAR_TYPE_KATAKANA = 7
CHAR_TYPE_KANJINUMERIC = 8
CHAR_TYPE_GREEK = 9
CHAR_TYPE_CYRILLIC = 10 

# Parses the sentence.  Returns an array of tokens.
def parse_sentence sentence
	nm = Natto::MeCab.new
	tokens = []

	nm.parse(sentence) do |token|
		unless token.feature.split(',').first == 'BOS/EOS'
			tokens << token
		end
	end

	return tokens
end

# Returns true iff a blank space should go before the token.
def needs_space_before? token
	#TODO Write this.
	return true
end

# Returns kana for a given token.
def token_to_kana token
	char_type = token.char_type
	surface = token.surface

	if (char_type == CHAR_TYPE_KANJI) or (char_type == CHAR_TYPE_HIRAGANA)
		katakana = token.feature.split(',')[-2]
		hiragana = NKF.nkf('-h1 -w', katakana)
		text = hiragana
	else
		text = surface
	end

	# Put space between some tokens.
	if needs_space_before? token
		text = ' ' + text
	end

	return text
end

def make_kana sentence
	tokens = parse_sentence sentence
	s = ''

	tokens.each do |token|
		s += token_to_kana token
	end

	return s
end

def test
	sentences = ['彼はいちごケーキが大好きです。', 'どうぞよろしくお願いします。', 'あなたは猫を飼っているよね。']

	sentences.each do |sentence|
		puts '漢字： ' + sentence
		puts 'かな： ' + (make_kana sentence)
	end
end

test
