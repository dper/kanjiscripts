#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# word_finder.rb
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

Script_dir = File.dirname(__FILE__)
require Script_dir + '/../' + 'kana'

Pairs = 'pairs.txt'

# A large list of Japanese and English sentences.
class Corpus
	# Creates a Corpus.
	def initialize max_sentence_length
		@max_sentence_length = max_sentence_length

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

		puts "Corpus sentence pairs: " + pairs.size.to_s + "."

		# Removes pairs where the Japanese half already appeared.
		# Some sentences have multiple translations.  We use one.
		pairs.uniq! { |pair| pair["japanese"] }
		puts "Unique corpus sentence pairs: " + pairs.size.to_s + "."
		
		# Remove long sentences.
		pairs.select! { |pair| pair["japanese"].size <= @max_sentence_length }
		puts "Maximum sentence length: " + @max_sentence_length.to_s + "."
		puts "Short sentence pairs: " + pairs.size.to_s + "."

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
	# Creates a Finder.
	def initialize max_sentence_length
		@corpus = Corpus.new max_sentence_length
	end

	# Outputs some information on what was found.
	def analyze
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
	def find_sentences sentences_per_word
		@results = @corpus.find_words @words

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
			japanese = sentence["japanese"]
			english = sentence["english"]
			kana = (PhoneticSentence.new japanese).kana
			triples << japanese + "\t" + kana + "\t" + english + "\n"
		end

		return triples
	end
end
