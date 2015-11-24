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

require "cgi"
require './finder.rb'

# Finds words in sentences and makes lists of those sentences.
class Text_Finder
	# Stores information from forms.
	# Ridiculous search parameters are adjusted.
	def get_parameters cgi
		@max_sentence_length = Integer(cgi['max_sentence_length'])

		if @max_sentence_length < 1
			@max_sentence_length = 1
		elsif @max_sentence_length > 1000
			@max_sentence_length = 1000
		end

		@sentences_per_word = Integer(cgi['sentences_per_word'])

		if @sentences_per_word < 1
			@sentences_per_word = 1
		elsif @sentences_per_word > 1000
			@sentences_per_word = 1000
		end

		text = cgi['words']

		if text.size > 10000
			puts "<p style=\"color: red;\">Error: Input too long.</p>\n"
			raise "Input too long."
		end

		text.gsub!("　", " ") # Handle full-width spaces.
		text.gsub!("\n", " ") # Handle line breaks.
		words = text.split.uniq

		words.select! {|word| word.size < 100}
		words.reject! {|word| word.ascii_only?}
		words.reject! {|word| /[[:cntrl:]]/.match word}
		words.reject! {|word| /[[:ascii:]]/.match word}

		words.uniq!

		if words.size > 5000
			puts "<p style=\"color: red;\">Error: Too many words.</p>\n"
			raise "Too many words."
		end

		@words = words
	end

	# Creates a Finder.
	def initialize cgi

		get_parameters cgi
		@finder = Finder.new @max_sentence_length
		corpus_information = @finder.get_corpus_information
		unique = corpus_information['unique_pairs']
		short = corpus_information['short_pairs']
		puts "<p>\n"
		mtime = (File.mtime 'pairs.txt').strftime "%Y-%m-%d"
		puts '<div>Pairs file updated: ' + mtime + ".</div>\n"
		puts '<div>Unique corpus pairs: ' + unique.to_s + ".</div>\n"
		puts '<div>Short corpus pairs: ' + short.to_s + ".</div>\n"
	end

	# Looks up the words in the corpus.
	def find_sentences
		puts '<div>Maximum sentence length: ' + @max_sentence_length.to_s + ".</div>\n"
		puts '<div>Desired sentences per word: ' + @sentences_per_word.to_s + ".</div>\n"
		puts '<div>Words sought: ' + @words.length.to_s + ".</div>\n"
		sought = @sentences_per_word * @words.length
		puts '<div>Sentences sought: ' + sought.to_s + ".</div>\n"
		
		totals = @finder.find_sentences @words, @sentences_per_word
		puts '<div>Non-unique sentences found: ' + totals['non-unique'].to_s + ".</div>\n"
		puts '<div>Unique sentences found: ' + totals['unique'].to_s + ".</div>\n"
		puts "</p>\n"

		information = ''

		@finder.get_search_information.each do |result|
			information += result['found'].to_s + "\t" + result['word'] + "\n"
		end

		information = @finder.get_search_information.map { |result|
			result['found'].to_s + "\t" + result['word']
		}.join "\n"

		puts "<p>\n"
		puts "<textarea readonly cols=\"20\" rows=\"10\">\n"
		puts information + "</textarea>\n"
		puts "</p>\n"
	end

	# Writes the sentences to the output file.
	def write_sentences
		target_sentences = 'target_sentences.txt'
		sentences = @finder.get_sentences

		output = ''

		sentences.each do |sentence|
			output += sentence
		end

		output.chomp!("\n")

		puts "<p>\n"
		puts "<textarea readonly cols=\"200\" rows=\"20\">\n"
		puts output + "</textarea>\n"
		puts "</p>\n"
	end
end

cgi = CGI.new
puts cgi.header
puts "<!DOCTYPE html>\n"
puts "<html>\n"
puts "<head>\n"
puts "<meta charset=\"utf-8\" />\n"
puts "</head>\n"
puts "<body style=\"text-align: center;\">\n"
puts "<h1>Details</h1>\n"

$text_finder = Text_Finder.new cgi
$text_finder.find_sentences

puts "<h1>Results</h1>\n"
$text_finder.write_sentences

puts "</body>\n"
puts "</html>\n"
