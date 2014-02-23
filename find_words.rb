#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# find_words.rb
#
# == USAGE
# ./find_words.rb
#
# == DESCRIPTION
# A script that takes a list of words and makes a list of sentences.
# Each sentence is in Japanese and English.
# The target words must be in the file target_words.txt.
# The output is written to the file target_sentences.txt.
#
# == AUTHOR
# Douglas P Perkins - https://dperkins.org - https://microca.st/dper

Pairs = 'pairs.txt'
Target_words = 'target_words.txt'
Target_sentences = 'target_sentences.txt'

Script_dir = File.dirname(__FILE__)

$verbose = true

# Displays an error message if verbose operation is enabled.
def verbose message
	if $verbose
		puts message
	end
end

# A large list of Japanese and English sentences.
class Corpus
	# Creates a Corpus.
	def initialize
		verbose 'Reading ' + Pairs + ' ...'
		path = Script_dir + '/' + Pairs
		@text = IO.readlines path
	end

	# Finds all the example sentences containing a given word.
	def find_word word
		results = []

		@text.each do |line|
			japanese = line.split("\t").first
			
			if japanese.include? word
				results << line
			end
		end

		return results
	end

	# Finds all the example sentences for each of the given words.
	# Returns a hash from the words to arrays of sentences.
	def find_words words
		results = {}

		words.each do |word|
			results[word] = find_word word
		end

		return results
	end
end

# Finds words in sentences and makes lists of those sentences.
class Finder
	# Reads the target word file
	def read_target_file
		verbose 'Reading ' + Target_words + ' ...'
		path = Script_dir + '/' + Target_words
		text = IO.readlines path

		@words = []

		text.each do |line|
			@words.concat line.split
		end
	end

	# Creates a Finder.
	def initialize corpus
		@corpus = corpus
		read_target_file
		verbose @words
	end

	#TODO Stuff.
end

$corpus = Corpus.new
$finder = Finder.new $corpus
