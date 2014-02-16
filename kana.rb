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
			sides['left'] = tokens[index - 1]
		end

		unless tokens.last == token
			sides['right'] = tokens[index + 1]
		end

		neighbors[token] = sides
	end

	return neighbors
end

# Returns kana for a given token.
def token_to_kana token
	char_type = token.char_type

	if (char_type == 2) or (char_type == 6)
		yomi = token.feature.split(',')[-2]
		return NKF.nkf('-h1 -w', yomi)
	else
		return token.surface
	end
end

# Returns spacing to go before the token, if necessary.
# If no spacing is needed, returns the empty string.
def make_spacing (token, neighbors)
	def type token
		return token.feature.split(',').first
	end

	# If it's the first token, no spacing is needed.
	unless neighbors[token]['left']
		return ''
	end

	type = type token
	left_type = type neighbors[token]['left']

	#puts token.surface + ' // ' + token.feature.split(',').first
	puts token.surface + ' // ' + token.char_type.to_s

	# Do not split neighboring verbs.
	if type.include? '動詞' and left_type.include? '動詞'
		return ''
	end

	# Do not split neighboring nouns.
	if type.include? '名詞' and left_type.include? '名詞'
		return ''
	end

	# Do not splt punctuation.
	if (type token) == '記号'
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
	sentences = ['彼はいちごケーキが大好きです。', 'よろしくお願いします。', '彼女は８２歳です。', '私は行きます。']

	sentences.each do |sentence|
		puts '---------- 漢字： ' + sentence
		puts '---------- かな： ' + (make_kana sentence)
	end
end

test
