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

# Sentences filter.
class SentencesFilter
	# Parses the corpus sentence file.	
	def filter_sentences
		puts 'Parsing ' + Sentences_detailed + ' ...'
		path = Sentences_detailed
		text = IO.readlines path
		sentences = []

		# The sentences file has lines like this:
		# 	id [tab] lang [tab] text [tab] username [tab] date_added [tab] date_last_modified.
		# The id is the sentence id.
		# The text is the sentence.
		# The username is the user who has adopted the sentence.

		text.each do |line|
			lang = line.split("\t")[1]

			if lang == 'eng' or lang == 'jpn'
				#TODO Write it.
			end
		end

		#TODO Write it.
	end

	# Creates a Corpus.
	def initialize
		filter_sentences	
	end
end

$sentencesFilter = SentencesFilter.new
