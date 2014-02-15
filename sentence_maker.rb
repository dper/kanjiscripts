#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# sentence_maker.rb
#
# == USAGE
# ./sentence_maker.rb
#
# == DESCRIPTION
# A script that takes a list of Japanese words and finds sentences for them.
#
# This script depends on several files having proper formatting located
# in the same directory. See the README for file source information.
#
# == AUTHOR
# Douglas P Perkins - https://dperkins.org - https://microca.st/dper

$verbose = true

# Displays an error message if verbose operation is enabled.
def verbose message
	if $verbose
		puts message
	end
end

Script_dir = File.dirname(__FILE__)

# Sentence corpus.
class Corpus
	# Parses tags file.
	def parse_tags
		path = Script_dir + '/tags.csv'
		text = IO.readlines path
		
		# The tags file is a bunch of lines like this: sentence_id [tab] tag_name .
		# The sentence ID is a number of a sentence. Tags can be multiple words with spaces.
		# If a sentence is tagged several times, each one is a separate line.
		
		@tags = {}
		
		text.each do |line|
			sentence_id = line.split[0].to_i
			tag = line.split[1]
			
			if @tags.key? sentence_id
				@tags[sentence_id] << tag
			else
				@tags[sentence_id] = [tag]
			end
		end
	end
	
	# Reads
	def parse_indices
		path = Script_dir + '/jpn_indices.csv'
		text = IO.readlines path
		
		# The indices file is a bunch of lines like this: sentence_id [tab] meaning_id [tab] text.
		# The sentence_id is the Japanese sentence.
		# The meaning_id is an English translation of it.
		# The text is a heavily annotated Japanese sentence.
		
		@translation = {}
		
		text.each do |line|
			sentence_id = line.split[0].to_i
			meaning_id = line.split[1].to_i
			
			if @tags.key? sentence_id
				@tags[sentence_id] << meaning_id
			else
				@tags[sentence_id] = [meaning_id]
			end
		end
	end
	
	def parse_sentences
		path = Script_dir + '/sentences_detailed.csv'
		text = IO.readlines path
		#TODO	
		
		# If a sentence isn't Japanese or English, ignore it.
		# If a sentence isn't adopted, ignore it.
		# If a sentence has a bad tag on it, ignore it.				
		
		# Make two maps.  One maps IDs to English.  The other maps IDs to Japanese.
	end

	# Creates a Corpus.
	def initialize
		verbose 'Parsing tags.csv ...'
		parse_tags
		verbose 'Parsing jpn_indices.csv ...'
		parse_indices
		verbose 'Parsing sentences_detailed.csv ...'
		parse_sentences	
		
		#TODO Filter the sentences. 
	end
	
	#TODO Write a function that for a word makes a list of containing sentences.
	#TODO Probably these sentences should be sorted by length: shortest first.
end

#TODO Read a word list.

$corpus = Corpus.new
#TODO Use the corpus.
