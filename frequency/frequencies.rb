#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# frequencies.rb
#
# == USAGE
# ./frequencies.rb
#
# == DESCRIPTION
# Shows Japanese word frequency lists.
#
# This script depends on the file term_aggregates.txt being in
# the tatoeba subdirectory.  Download them before use.
#
# == AUTHOR
# Douglas Perkins - https://dperkins.org - https://microca.st/dper

Script_dir = File.dirname(__FILE__)
Aggregates = 'term_aggregates.txt'

class Frequencies
	def initialize
		@words = []

		puts 'Parsing ' + Aggregates + ' ...'
		path = Script_dir + '/' + Aggregates
		text = IO.readlines path

		# The original data file lists the least common words first.
		# It is more convenient for us to list the most common words first.
		text.reverse!

		# Each line in the file gives frequency data for one word.
		# The format is freq [tab] word [tab] part of speech.
		# It seems both single and double tabs are used.

		text.each do |line|
			@words << { "text" => line.split[1], "pos" => line.split.last }
		end		
	end

	def get_speech_type type
		filtered_words = @words.keep_if { |word| word["pos"] == type }
		return filtered_words.map { |word| word["text"] }
	end


	# Returns a list of the adverbs.
	def get_adverbs
		return get_speech_type '副詞'
	end

	# Returns a list of the adjectives.
	def get_adjectives
		return get_speech_type '形容詞'
	end

	# Returns a list of the nouns.
	def get_adjectives
		return get_speech_type '名詞'
	end

	# Returns a list of the verbs.
	def get_adjectives
		return get_speech_type '動詞'
	end

	# Returns a list of the particles.
	def get_particles
		return get_speech_type '助詞'
	end

	# Returns a list of the interjections.
	def get_particles
		return get_speech_type '感動詞'
	end

	# Returns a list of the conjunctions.
	def get_conjunctions
		return get_speech_type '接続詞'
	end
end

$frequencies = Frequencies.new
puts $frequencies.get_adverbs
