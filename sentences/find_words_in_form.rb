#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# find_words_in_form.rb
#
# == USAGE
# Call this from an HTML form.
#
# == DESCRIPTION
# A script that takes a list of words and makes a list of sentences.
# Each sentence is in Japanese and English.
#
# == AUTHOR
# Douglas Perkins - https://dperkins.org - https://microca.st/dper

Script_dir = File.dirname(__FILE__)
require "cgi"
require './word_finder.rb'

# Finds words in sentences and makes lists of those sentences.
class Text_Finder
	# Stores information from forms.
	def get_parameters cgi
		@max_sentence_length = cgi['max_sentence_length']
		@sentences_per_word = cgi['sentences_per_word']

		text = cgi['words']

		words = text.split
		@words = words.uniq
	end

	# Creates a Finder.
	def initialize cgi
		get_parameters cgi
		@finder = Finder.new @max_sentence_length
		corpus_information = @finder.get_corpus_information
		unique = corpus_information['unique_pairs']
		short = corpus_information['short_pairs']
		puts 'Unique corpus pairs: ' + unique.to_s + '.'
		puts 'Short corpus pairs: ' + short.to_s + '.'
	end

	# Looks up the words in the corpus.
	def find_sentences
		puts 'Maximum sentence length: ' + @max_sentence_length.to_s + '.'
		puts 'Desired sentences per word: ' + @sentences_per_word.to_s + '.'
		puts 'Words sought: ' + @words.length.to_s + '.'
		sought = @sentences_per_word * @words.length
		puts 'Sentences sought: ' + sought.to_s + '.'
		puts 'Finding words in the corpus ...'
		puts '-------------------------------'
		
		totals = @finder.find_sentences @words, @sentences_per_word
		
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

cgi = CGI.new
puts cgi.header
puts "<!DOCTYPE html>\n"
puts "<html>\n"
puts "<head>\n"
puts "<meta charset=\"utf-8\" />\n"
puts "</head>\n"
puts "<body>\n"
puts "Yay."

$text_finder = Text_Finder.new cgi
#$text_finder.find_sentences
#$text_finder.write_sentences

puts "Yay again."
puts "</body>\n"
puts "</html>\n"
