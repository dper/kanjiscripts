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

	type = type token

	puts type + ' / ' + token.char_type.to_s + ' / ' + token.surface
	puts token
	puts

	left = neighbors[token]['left']
	right = neighbors[token]['right']

	# If it's the first token, no spacing is needed.
	unless left
		return ''
	end

	left_type = type left

	case type
		# Nouns.
		when '名詞'
			# Numbers shouldn't be spaced from nouns.
			unless token.char_type == 4 and left_type == '名詞'
				return ' '
			end

		# Verbs.
		when '動詞'
			if left_type == '名詞' then return ' ' end

			# A particle surrounded by verbs doesn't need space, but others do.
			if left_type == '助詞'
				two_left = neighbors[left]['left']
				if two_left and (type two_left) != '動詞' then return ' ' end
			end

		# Helping verbs.
		when '助動詞'
			if token.surface == 'です' then return ' ' end
			if left_type = '名詞' then return ' ' end

		# Particles.
		when '助詞'
			if left_type == '名詞' then return ' ' end

		# Pre-noun adjectival.
		when '連体詞'
			# Do nothing.

		# Punctuation.
		when '記号'
			# Do nothing.
	end

	return ''
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
	sentences = ['彼はいちごケーキが大好きです。', 'よろしくお願いします。', '彼女は８２歳です。', '私は行きます。', 'となりに住んでいる二人は去年結婚していました。', 'その本を箱の中に入れてください。', '元気な男の子ですよね。']

	sentences.each do |sentence|
		puts '---------- 漢字： ' + sentence
		puts '---------- かな： ' + (make_kana sentence)
	end
end

test
