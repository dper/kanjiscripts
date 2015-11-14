#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# find_words_from_file.rb
#
# == USAGE
# ./find_words_from_file.rb
#
# == DESCRIPTION
# A script that takes a list of words and makes a list of sentences.
# Each sentence is in Japanese and English.
#
# The file pairs.txt must be in the same directory.
# It is produced by the make_pairs.rb script.
#
# The target words must be in the file target_words.txt.
# The output is written to the file target_sentences.txt.
#
# == AUTHOR
# Douglas Perkins - https://dperkins.org - https://microca.st/dper

Script_dir = File.dirname(__FILE__)
require Script_dir + '/' + 'word_finder.rb'

Target_words = 'target_words.txt'
Target_sentences = 'target_sentences.txt'

TARGET_SENTENCE_COUNT = 3
MAX_SENTENCE_LENGTH = 25


# Finds words in sentences and makes lists of those sentences.
class Text_Finder
	# Creates a Finder.
	def initialize
		puts 'Reading ' + Target_words + ' ...'
		path = Script_dir + '/' + Target_words
		text = IO.readlines path

		words = []
		text.each { |line| words.concat line.split }
		@words = words.uniq

		@finder = Finder.new MAX_SENTENCE_LENGTH
	end

	def analyze results
		total = 0

		puts 'Number of sentences found for each word:'

		@words.each do |word|
			found = results[word].length	
			puts found.to_s + "\t" + word
			total += found
		end

		sought = TARGET_SENTENCE_COUNT * @words.length
		puts 'Desired sentences per word: ' + TARGET_SENTENCE_COUNT.to_s + '.'
		puts 'Words sought: ' + @words.length.to_s + '.'
		puts 'Sentences sought: ' + sought.to_s + '.'
	end

	# Looks up the words in the corpus.
	def find_sentences
		puts 'Finding words in the corpus ...'

		totals = @finder.find_sentences TARGET_SENTENCE_COUNT

		puts 'Non-unique sentences found: ' + totals['non-unique'].to_s + '.'
		puts 'Unique sentences found: ' + totals['unique'].to_s + '.'
	end

	# Writes the sentences to the output file.
	def write_sentences
		puts 'Writing ' + Target_sentences + ' ...'
		sentences = @finder.get_sentences

		open(Target_sentences, 'w') do |file|
			sentences.each do |sentence|
				file.puts sentence
			end
		end	
	end
end

$text_finder = Text_Finder.new
$text_finder.find_sentences
$text_finder.write_sentences
