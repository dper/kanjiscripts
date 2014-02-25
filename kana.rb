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

# A sentence parsed by Natto is composed of tokens with the following properties.
# - :prev - pointer to previous node
# - :next - pointer to next node
# - :enext - pointer to the node which ends at the same position
# - :bnext - pointer to the node which starts at the same position
# - :surface - surface string; length may be obtainedi with length/rlength members
# - :feature - feature string
# - :id - unique node id
# - :length - length of surface form
# - :rlength - length of the surface form including white space before the morph
# - :rcAttr - right attribute id
# - :lcAttr - left attribute id
# - :posid - part-of-speech id
# - :char_type - character type
# - :stat - node status; 0 (NOR), 1 (UNK), 2 (BOS), 3 (EOS), 4 (EON)
# - :isbest - 1 if this node is best node
# - :alpha - forward accumulative log summation, only with marginal probability flag
# - :beta - backward accumulative log summation, only with marginal probability flag
# - :prob - marginal probability, only with marginal probability flag
# - :wcost - word cost
# - :cost - best accumulative cost from bos node to this node

# A Japanese sentence and its phonetic reading.
class PhoneticSentence
	attr_accessor :japanese # The Japanese sentence.
	attr_accessor :kana	# The phonetic reading.

	# Returns the token to the left of the argument, or nil if none.
	def find_left token
		index = @tokens.find_index token

		if index == 0
			return nil
		else
			return @tokens[index - 1]
		end
	end

	# Returns the token to the right of the argument, or nil if none.
	def find_right token
		index = @tokens.find_index token
		
		if index == @tokens.length - 1
			return nil
		else
			return @tokens[index + 1]
		end
	end

	# Returns true iff a blank space should go before the token.
	def pad token
		pos = pos token
		left = find_left token
		right = find_right token

		# A leading token needs no lead spacing.
		if (@tokens.find_index token) == 0
			return false
		end

		# Consider what part of speech it and adjacent tokens are.
		case pos
		when '助詞'
			if right and (pos left) == '助詞'
				return false
			end
		when '記号'
			return false
		#TODO More and better checks should go here.
		end

		return true
	end

	# Returns the token's grammatical part of speech.
	def pos token
		return token.feature.split(',').first
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
		if pad token
			text = ' ' + text
		end

		return text
	end

	# Makes kana for the Japanese sentence.
	def make_kana
		kana = ''

		@tokens.each do |token|
			kana += token_to_kana token
		end

		@kana = kana
	end

	# Parses the Japanese.
	def parse
		nm = Natto::MeCab.new
		tokens = []

		nm.parse(@japanese) do |token|
			unless token.feature.split(',').first == 'BOS/EOS'
				tokens << token
			end
		end

		@tokens = tokens
	end

	# Makes a PhoneticSentence.
	def initialize japanese
		@japanese = japanese.dup
		parse
		make_kana
	end
end



def test
	sentences = ['彼はいちごケーキが大好きです。', 'どうぞよろしくお願いします。', 'あなたは猫を飼っているよね。']

	sentences.each do |sentence|
		puts '漢字： ' + sentence
		s = PhoneticSentence.new sentence
		puts 'かな： ' + s.kana
	end
end

test
