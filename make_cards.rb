#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# make_cards.rb
#
# == USAGE
# ./make_cards.rb
#
# == DESCRIPTION
# A script that creates a tab-separated flash card file from Tatoeba.
# Sentences are included if they are in English-Japanese pairs.
# Only sentences with safe-looking tags are included.
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

# A note for a flash card containing a sentence in kanji, kana, and English.
class Note
	attr_accessor :kanji	# The kanji sentence.
	attr_accessor :kana	# The kana reading of the sentence.
	attr_accessor :english	# The English meaning of the sentence.

	# Generates the kana.
	def make_kana kanji
		#TODO Write this.
		return 'かな'
	end

	# Creates a Note.
	def initialize(kanji, english)
		@kanji = kanji
		@english = english
		@kana = make_kana kanji
	end
end

# Sentence corpus.
class Corpus
	attr_accessor :notes	# Notes for the Japanese/English sentence pairs.

	# Parses tags file.
	def parse_tags
		path = Script_dir + '/tags.csv'
		text = IO.readlines path
		
		# The tags file is a bunch of lines like this: sentence_id [tab] tag_name .
		# The sentence ID is a number of a sentence. Tags can be multiple words with spaces.
		# If a sentence is tagged several times, each one is a separate line.
		
		@tags = {}
		
		text.each do |line|
			sentence_id = line.split("\t")[0].to_i
			tag = line.split("\t")[1]
			
			if @tags.key? sentence_id
				@tags[sentence_id] << tag
			else
				@tags[sentence_id] = [tag]
			end
		end

		verbose 'Unfiltered tags: ' + @tags.size.to_s + '.'
	end
	
	# Parses the Japanese-English pair index file.
	def parse_indices
		path = Script_dir + '/jpn_indices.csv'
		text = IO.readlines path
		@pairs = []
		
		# The indices file has lines like this: sentence_id [tab] meaning_id [tab] text.
		# The sentence_id is the Japanese sentence.
		# The meaning_id is an English translation of it.
		# The text is a heavily annotated Japanese sentence.
		
		text.each do |line|
			sentence_id = line.split("\t")[0].to_i
			meaning_id = line.split("\t")[1].to_i
			@pairs << [sentence_id, meaning_id]
		end

		verbose 'Unfiltered English/Japanese pairs: ' + @pairs.size.to_s + '.'
	end

	# Parses the corpus sentence file.	
	def parse_sentences
		path = Script_dir + '/sentences_detailed.csv'
		text = IO.readlines path
		@english = {}
		@japanese = {}
		@usernames = {}

		# The sentences file has lines like this:
		# 	id [tab] lang [tab] text [tab] username [tab] date_added [tab] date_last_modified.
		# The id is the sentence id.
		# The text is the sentence.
		# The username is the user who has adopted the sentence.

		text.each do |line|
			id = line.split("\t")[0].to_i
			lang = line.split("\t")[1]
			text = line.split("\t")[2]
			username = line.split("\t")[3]

			if lang == 'eng'
				@english[id] = text
				@usernames[id] = username
			elsif lang == 'jpn'
				@japanese[id] = text
				@usernames[id] = username
			end
		end

		verbose 'Unfiltered English sentences: ' + @english.size.to_s + '.'
		verbose 'Unfiltered Japanese sentences: ' + @japanese.size.to_s + '.'
	end

	# Returns true iff the sentence is adopted.
	def adopted? id
		return @usernames[id] != '\N'
	end

	# Returns true iff the tags are all safe.
	def safe_tags? id
		# If there are no tags, it is safe.
		unless @tags.key? id
			return true
		end

		# This list of prefixes of tags can be modified as desired.
		dangerous = ['@Check!', '@change', '@check', '@delete', '@duplicate', '@fragment', '@need native', '@needs', '@not a sentences', '@wrong', 'ambigous', 'ambiguos', 'ambiguous', 'baby talk', 'check eng']

		# Examine each tag.  If it's dangerous, return false.
		@tags[id].each do |tag|
			dangerous.each do |prefix|
				# Checks to see if the tag starts with the prefix.
				if tag[0, prefix.length] == prefix
					return false
				end
			end
		end

		return true
	end
	
	# Makes notes for each of the Japanese/English sentence pairs.
	def make_notes
		notes = []
		not_adopted = 0
		unsafe_tags = 0
		sentence_not_found = 0
		meaning_not_found = 0

		@pairs.each do |pair|
			sentence_id = pair[0]
			meaning_id = pair[1]

			# Unadopted sentences aren't used.
			unless (adopted? sentence_id) and (adopted? meaning_id)
				not_adopted += 1
				next
			end

			# Only sentences with safe tags are used.
			unless (safe_tags? sentence_id) and (safe_tags? meaning_id)
				unsafe_tags += 1
				next
			end

			sentence = @japanese[sentence_id]
			meaning = @english[meaning_id]

			if not sentence
				sentence_not_found += 1
				verbose 'Warning: Sentence ' + sentence_id.to_s + ' not found.  Skipping.'
				next
			end

			if not meaning
				meaning_not_found += 1
				verbose 'Warning: Meaning ' + meaning_id.to_s + ' not found.  Skipping.'
				next
			end

			notes << Note.new(sentence, meaning)
		end

		@notes = notes
		verbose 'Not adopted pairs: ' + not_adopted.to_s + '.'
		verbose 'Unsafe tags pairs: ' + unsafe_tags.to_s + '.'
		verbose 'Sentence not found: ' + sentence_not_found.to_s + '.'
		verbose 'Meaning not found: ' + meaning_not_found.to_s + '.'
		verbose 'English/Japanese notes: ' + notes.size.to_s + '.'
	end

	# Creates a Corpus.
	def initialize
		verbose 'Parsing tags.csv ...'
		parse_tags
		verbose 'Parsing jpn_indices.csv ...'
		parse_indices
		verbose 'Parsing sentences_detailed.csv ...'
		parse_sentences	
		verbose 'Making notes for sentence pairs ...'
		make_notes
	end
end

# Prints a list of notes.
def write_notes notes
	verbose 'Writing notes...'
	verbose ''

	notes.each do |note|
		puts note.kanji + "\t" + note.kana + "\t" + note.english
	end
end

$corpus = Corpus.new
write_notes $corpus.notes
