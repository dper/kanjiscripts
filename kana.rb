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

# Returns a hash of neighbors for an array of tokens.
def find_neighbors tokens
	neighbors = {}

	tokens.each_with_index do |token, index|
		sides = {}

		unless tokens.first == token
			sides['left'] = index - 1
		end

		unless tokens.last == token
			sides['right'] = index + 1
		end

		neighbors[token] = sides
	end

	return neighbors
end

# Returns kana for a given token.
def token_to_kana token
	if token.char_type == 2
		yomi = token.feature.split(',')[-2]
		return NKF.nkf('-h1 -w', yomi)
	else
		return token.surface
	end
end

# Returns spacing to go before the token, if necessary.
# If no spacing is needed, returns the empty string.
def make_spacing (token, neighbors)
	# If it's the first token, no spacing is needed.
	unless neighbors[token]['left']
		return ''
	end

	return ' '
end

def make_kana sentence
	tokens = parse_sentence sentence
	neighbors = find_neighbors tokens
	kana = ''

	tokens.each do |token|
		kana += make_spacing(token, neighbors)
		kana += token_to_kana token
	end

	return kana
end

def test
	sentences = ['彼はケーキが大好きです。', 'よろしくお願いします。']

	sentences.each do |sentence|
		puts '---------- 漢字： ' + sentence
		puts '---------- かな： ' + (make_kana sentence)
	end
end

test
