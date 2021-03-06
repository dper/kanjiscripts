#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# filter.rb
#
# == USAGE
# ./filter.rb
#
# == DESCRIPTION
# A script that filters out sentences, leaving only English and Japanese.
#
# This script depends on the file sentences_detailed.csv.
# See the README for more information.
#
# == AUTHOR
# Douglas Perkins

Sentences_detailed = 'sentences_detailed.csv'
Sentences_filtered = 'sentences_filtered.csv'

# Sentences filter.
class SentencesFilter
	# Parses the corpus sentence file.	
	def filter_sentences
		puts 'Filtering ' + Sentences_detailed + '.'
		path = Sentences_detailed
		text = IO.readlines path
		sentences = []

		# The sentences file has lines like this:
		# 	id [tab] lang [tab] text [tab] username [tab] date_added [tab] date_last_modified.
		# Here we only care about the language.

		puts 'Total lines: ' + text.size.to_s

		text.each_with_index do |line, i|
			if (i % 10000) == 0
				printf("\rLine:        " + i.to_s)
			end

			line.encode!('UTF-8', 'UTF-8', :invalid => :replace)
			lang = line.split("\t")[1]

			if lang == 'eng' or lang == 'jpn'
				sentences << line
			end
		end

		puts "\r" + 'Line:        ' + text.size.to_s

		File.open(Sentences_filtered, 'w') do |file|
			sentences.each { |sentence| file.puts(sentence) }
		end

		puts 'Retaining:   ' + sentences.length.to_s
		puts 'Saved to ' + Sentences_filtered + '.'
	end

	# Creates a Corpus.
	def initialize
		filter_sentences	
	end
end

$sentencesFilter = SentencesFilter.new
