#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# finder.rb
#
# == USAGE
# This is a library. Don't call it directly.
#
# == DESCRIPTION
# A script that takes a list of words and makes a list of sentences.
# Each sentence is in Japanese and English.
#
# == AUTHOR
# Douglas Perkins
# https://dperkins.org
# https://microca.st/dper

require '../kana.rb'

# A large list of Japanese and English sentences.
class Corpus
	# Sentence pair count information.
	attr_accessor :information

	# Creates a Corpus.
	def initialize max_sentence_length
		@max_sentence_length = max_sentence_length

		path = './pairs.txt'
		text = IO.readlines path
		pairs = []

		text.each do |line|
			# Ignore lines that start with #.
			if line.start_with? '#'
				next
			end

			pair = {}
			pair['japanese'] = line.split("\t").first
			pair['english'] = line.split("\t").last.chomp
			pairs << pair
		end

		@information = {}
		@information['pairs'] = pairs.size

		# Removes pairs where the Japanese half already appeared.
		# Some sentences have multiple translations.  We use one.
		pairs.uniq! { |pair| pair["japanese"] }
		@information['unique_pairs'] = pairs.size
		
		# Remove long sentences.
		pairs.select! { |pair| pair["japanese"].size <= @max_sentence_length }

		@information['short_pairs'] = pairs.size

		@pairs = pairs

	end

	# Finds all the example sentences containing a given word.
	def find_word word
		results = []

		@pairs.each do |pair|
			if pair['japanese'].include? word
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
	# Creates a Finder.
	def initialize max_sentence_length
		@corpus = Corpus.new max_sentence_length
	end

	# Returns information about the corpus sentence count.
	def get_corpus_information
		return @corpus.information
	end

	# Returns word and sentence count information on what was found.
	def get_search_information
		information = []

		@words.each do |word|
			found = @results[word].length	
			information << {'word' => word, 'found' => found}
		end

		return information
	end

	# Looks up the words in the corpus.
	def find_sentences (words, sentences_per_word)
		@words = words
		@results = @corpus.find_words words

		sentences = []

		@words.each do |word|
			result = @results[word].take sentences_per_word
			sentences = sentences + result
		end

		@sentences = sentences.uniq

		totals = {}
		totals['non-unique'] = sentences.length.to_s
		totals['unique'] = @sentences.length.to_s
		return totals
	end

	# Returns the sentence triples.
	def get_sentences
		triples = []

		@sentences.each do |sentence|
			japanese = sentence['japanese']
			english = sentence['english']
			kana = (PhoneticSentence.new japanese).kana
			triples << japanese + "\t" + kana + "\t" + english + "\n"
		end

		return triples
	end
end
