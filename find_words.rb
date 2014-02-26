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

Script_dir = File.dirname(__FILE__)
require Script_dir + '/' + 'kana'

Pairs = 'pairs.txt'
Target_words = 'target_words.txt'
Target_sentences = 'target_sentences.txt'
TARGET_SENTENCE_COUNT = 5

# A large list of Japanese and English sentences.
class Corpus
	# Creates a Corpus.
	def initialize
		puts 'Reading ' + Pairs + ' ...'
		path = Script_dir + '/' + Pairs
		text = IO.readlines path
		pairs = []

		text.each do |line|
			# Ignore lines that start with #.
			if line.start_with? '#'
				next
			end

			pair = {}
			pair["japanese"] = line.split("\t").first
			pair["english"] = line.split("\t").last.chomp
			pairs << pair
		end

		# Removes pairs where the Japanese half already appeared.
		# Some sentences have multiple translations.  We use one.
		pairs.uniq! { |pair| pair["japanese"] }

		@pairs = pairs
	end

	# Finds all the example sentences containing a given word.
	def find_word word
		results = []

		@pairs.each do |pair|
			if pair["japanese"].include? word
				results << pair
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
		puts 'Reading ' + Target_words + ' ...'
		path = Script_dir + '/' + Target_words
		text = IO.readlines path

		words = []

		text.each do |line|
			words.concat line.split
		end

		@words = words.uniq
	end

	# Creates a Finder.
	def initialize corpus
		@corpus = corpus
		read_target_file
		puts @words
	end

	# Looks up the words in the corpus.
	def find_words
		results = @corpus.find_words @words

		#TODO Compare the target count with the actual count.

		#TODO Take the first few sentences from each word.
		#TODO Put them in the output file.
		puts results['秋田']
	end
end

$corpus = Corpus.new
$finder = Finder.new $corpus
$finder.find_words
