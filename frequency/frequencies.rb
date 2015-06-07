#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# frequencies.rb
#
# == USAGE
# ./frequencies.rb
#
# == DESCRIPTION
# Shows Japanese word frequency lists.
#
# This script depends on the file term_aggregates.txt being in
# the tatoeba subdirectory.  Download them before use.
#
# == AUTHOR
# Douglas Perkins - https://dperkins.org - https://microca.st/dper

Script_dir = File.dirname(__FILE__)
Aggregates = 'term_aggregates.txt'

class Frequencies
	def initialize
		@words = []

		path = Script_dir + '/' + Aggregates
		text = IO.readlines path

		# The original data file lists the least common words first.
		# It is more convenient for us to list the most common words first.
		text.reverse!

		# Each line in the file gives frequency data for one word.
		# The format is freq [tab] word [tab] part of speech.
		# It seems both single and double tabs are used.

		text.each do |line|
			@words << { "text" => line.split[1], "pos" => line.split.last }
		end		
	end

	def get_word_type (type)
		filtered_words = @words.keep_if { |word| word["pos"] == type }
		return filtered_words.map { |word| word["text"] }
	end
end

# Finds words of the type specified as command line arguments.
def find_frequencies
	pos = case ARGV[0]
		when 'adjectives' then '形容詞'
		when 'adverbs' then '副詞'
		when 'conjunctions' then '接続詞'
		when 'interjections' then '感動詞'
		when 'nouns' then '名詞'
		when 'particles' then '助詞'
		when 'verbs' then '動詞'
		else nil 
	end

	count = ARGV.length == 2 ? ARGV[1].to_i : 0

	if pos then
		$frequencies = Frequencies.new
		words = $frequencies.get_word_type pos

		if count and count > 0
			words = words[0, count]	
		end

		puts words
	else
		puts 'Error: Invalid part of speech.'
	end
end

if ARGV.length == 0
	# If run without arguments, show valid arguments.
	puts "This program shows common Japanese words.  The words are sorted by common speech.  Valid choices: nouns, verbs, adjectives, adverbs, particles, interjections, and conjunctions.  A certain number of words can be requested.  If the number of words is not specified, as many as possible are shown.\n\nExample uses:\n./frequencies.rb nouns 100\n./frequencies.rb prepositions 50"
else
	find_frequencies
end
