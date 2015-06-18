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
#
# The file pairs.txt must be in the same directory.
# It is produced by the make_pairs.rb script.
#
# The target words must be in the file target_words.txt.
# The output is written to the file target_sentences.txt.
#
# == AUTHOR
# Douglas Perkins - https://dperkins.org - https://microca.st/dper

Script_dir = File.dirname(__FILE__)
require Script_dir + '/../' + 'kana'

Pairs = 'pairs.txt'
Target_words = 'target_words.txt'
Target_sentences = 'target_sentences.txt'

TARGET_SENTENCE_COUNT = 3
MAX_SENTENCE_LENGTH = 20

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

		puts "Corpus sentence pairs: " + pairs.size.to_s + "."

		# Removes pairs where the Japanese half already appeared.
		# Some sentences have multiple translations.  We use one.
		pairs.uniq! { |pair| pair["japanese"] }
		puts "Unique corpus sentence pairs: " + pairs.size.to_s + "."
		
		# Remove long sentences.
		pairs.select! { |pair| pair["japanese"].size <= MAX_SENTENCE_LENGTH }
		puts "Maximum sentence length: " + MAX_SENTENCE_LENGTH.to_s + "."
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
	end

	# Shows some statistical analysis.
	def analyze results
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
	def find_words
		puts 'Finding words in the corpus ...'

		results = @corpus.find_words @words
		analyze results

		sentences = []

		@words.each do |word|
			result = results[word].take TARGET_SENTENCE_COUNT
			sentences = sentences + result
		end

		@sentences = sentences.uniq
		puts 'Non-unique sentences found: ' + sentences.length.to_s + '.'
		puts 'Unique sentences found: ' + @sentences.length.to_s + '.'
	end

	# Writes the sentences to the output file.
	def write_sentences
		puts 'Writing ' + Target_sentences + ' ...'

		open(Target_sentences, 'w') do |file|
			@sentences.each do |sentence|
				japanese = sentence["japanese"]
				english = sentence["english"]
				kana = (PhoneticSentence.new japanese).kana
				s = japanese + "\t" + kana + "\t" + english
				file.puts s
			end
		end	
	end
end

$corpus = Corpus.new
$finder = Finder.new $corpus
$finder.find_words
$finder.write_sentences
