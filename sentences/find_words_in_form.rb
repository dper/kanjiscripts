#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# find_words_in_form.rb
#
# == USAGE
# ./find_words_in_form.rb
#
# == DESCRIPTION
# A script that takes a list of words and makes a list of sentences.
# Each sentence is in Japanese and English.
#
# This script should be called from the paired HTML input page.
#
# == AUTHOR
# Douglas Perkins - https://dperkins.org - https://microca.st/dper

require "cgi"
cgi = CGI.new
puts cgi.header
puts "<html><body>This is a test</body></html>"

Script_dir = File.dirname(__FILE__)
require './word_finder.rb'
puts "Success!"

# Finds words in sentences and makes lists of those sentences.
class Text_Finder
	TARGET_SENTENCE_COUNT = 3
	MAX_SENTENCE_LENGTH = 25

	# Creates a Finder.
	def initialize
		#TODO Get the text.

		words = []
		text.each { |line| words.concat line.split }
		@words = words.uniq

		@finder = Finder.new MAX_SENTENCE_LENGTH
		corpus_information = @finder.get_corpus_information
		unique = corpus_information['unique_pairs']
		short = corpus_information['short_pairs']
		puts 'Unique corpus pairs: ' + unique.to_s + '.'
		puts 'Short corpus pairs: ' + short.to_s + '.'
	end

	# Looks up the words in the corpus.
	def find_sentences
		puts 'Maximum sentence length: ' + MAX_SENTENCE_LENGTH.to_s + '.'
		puts 'Desired sentences per word: ' + TARGET_SENTENCE_COUNT.to_s + '.'
		puts 'Words sought: ' + @words.length.to_s + '.'
		sought = TARGET_SENTENCE_COUNT * @words.length
		puts 'Sentences sought: ' + sought.to_s + '.'
		puts 'Finding words in the corpus ...'
		puts '-------------------------------'
		
		totals = @finder.find_sentences @words, TARGET_SENTENCE_COUNT
		
		@finder.get_search_information.each do |result|
			puts result['found'].to_s + "\t" + result['word']
		end

		puts '-------------------------------'
		puts 'Non-unique sentences found: ' + totals['non-unique'].to_s + '.'
		puts 'Unique sentences found: ' + totals['unique'].to_s + '.'
	end

	# Writes the sentences to the output file.
	def write_sentences
		target_sentences = 'target_sentences.txt'
		puts 'Writing ' + target_sentences + ' ...'
		sentences = @finder.get_sentences

		output = ''

		sentences.each do |sentence|
			output += sentence + "\n"
		end
	end
end

#$text_finder = Text_Finder.new
#$text_finder.find_sentences
#$text_finder.write_sentences
