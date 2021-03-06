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
# This is a library.  Do not call it from the command line.
#
# == AUTHOR
# Douglas Perkins - https://dperkins.org - https://microca.st/dper

ENV['MECAB_PATH']='/usr/lib/x86_64-linux-gnu/libmecab.so.2'
require 'natto'
require 'nkf'

# A Japanese sentence and its phonetic reading.
class PhoneticSentence
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

	attr_accessor :japanese # The Japanese sentence.
	attr_accessor :kana	# The phonetic reading.

	# Returns the token's grammatical part of speech.
	def pos token
		return token.feature.split(',').first
	end

	# Returns the token's detailed part of speech.
	def detail token
		return token.feature.split(',')[1]
	end

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
		detail = detail token
		left = find_left token
		right = find_right token

		# A leading token needs no lead spacing.
		if (@tokens.find_index token) == 0
			return false
		end

		# No space is needed after punctuation.
		if left and (pos left) == '記号'
			return false
		end

		# This line is useful for debugging.
		#puts token.surface + ' ' + pos + ' ' + (detail token)

		# Consider what part of speech it and adjacent tokens are.
		case pos
		when '名詞'
			if (detail == '数') and left and (detail left) == '数'
				return false
			end

			if detail == '接尾'
				return false
			end
		when '動詞'
			if detail == '非自立'
				return false
			end

			if left and (pos left) == '動詞'
				return false
			end
		when '助動詞'
			if left and (pos left) == '動詞'
				return false
			end

			if left and (pos left) == '助動詞'
				return false
			end
		when '助詞'
			if right and (pos left) == '助詞'
				return false
			end

			if (detail == '接続助詞') and left and (pos left) == '動詞'
				return false
			end
		when '記号'
			return false
		end

		return true
	end

	# Returns kana for a given token.
	def token_to_kana token
		char_type = token.char_type
		surface = token.surface

		# This line is useful for debugging.
		#puts surface + ' ' + char_type.to_s

		if char_type == CHAR_TYPE_KANJI or char_type == CHAR_TYPE_KANJINUMERIC
			katakana = token.feature.split(',')[-2]
			hiragana = NKF.nkf('-h1 -w', katakana)
			text = hiragana
		elsif char_type == CHAR_TYPE_HIRAGANA
			katakana = token.feature.split(',')[-2]
			hiragana = NKF.nkf('-h1 -w', katakana)

			# In cases where a word isn't known, no kana can be produced.
			if katakana == '*'
				text = token.surface
			else
				text = hiragana
			end
		elsif char_type == CHAR_TYPE_NUMERIC
			text = surface
			
			counters = ['番', '月']
			last_character = text[-1]

			if counters.include? last_character
				katakana = token.feature.split(',')[-2]
				hiragana = NKF.nkf('-h1 -w', katakana)
				text = hiragana
			end
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

# A test method for this class.
def testPhoneticSentence
	sentences = []
	sentences << '彼はいちごケーキが大好きです。'
	sentences << 'どうぞよろしくお願いします。'
	sentences << 'あなたは猫を飼っているよね。'
	sentences << '今更どうしようもない事だ。'
	sentences << '私は１９８２年に生まれました。'
	sentences << '私は昨夜、遅くまで起きていた。'
	sentences << '私は1982年に生まれました。'
	sentences << '「トムとメアリーが離婚するって聞いたよ。」「それは噂だよ。」'
	sentences << '損害は千ドルと見積もりしています。'
	sentences << 'なんでにゃんにゃん言ってるの？'
	sentences << '彼女は２人姉妹がいます。'
	sentences << 'この顔にピンときたら110番！'
	sentences << 'この顔にピンときたら１１０番！'
	sentences << '努力したが何の成果も得られなかった。'
	sentences << '黄色いレインコートを着ている女の子はだれですか。'
	sentences << 'こんな暖かい陽気は2月にしては異常だ。'
	sentences << 'こんな暖かい陽気は２月にしては異常だ。'

	sentences.each do |sentence|
		puts '漢字： ' + sentence
		s = PhoneticSentence.new sentence
		puts 'かな： ' + s.kana
		puts ''
	end
end

# Uncomment this line for testing.
#testPhoneticSentence
