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

# Returns kana for a given token.
def token_to_kana token
	char_type = token.char_type

	if (char_type == 2) or (char_type == 6)
		katakana = token.feature.split(',')[-2]
		hiragana = NKF.nkf('-h1 -w', katakana)

		s = '<ruby>'
		s += token.surface
		s += '<rp>(</rp><rt>'
		s += hiragana
		s += '</rt><rp>)</rp></ruby>'
		return s
	else
		return token.surface
	end
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
	sentences = ['彼はいちごケーキが大好きです。']

	sentences.each do |sentence|
		puts '漢字： ' + sentence
		puts 'かな： ' + (make_kana sentence)
	end
end

test
