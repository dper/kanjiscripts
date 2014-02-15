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
			sentence_id = line.split[0].to_i
			tag = line.split[1]
			
			if @tags.key? sentence_id
				@tags[sentence_id] << tag
			else
				@tags[sentence_id] = [tag]
			end
		end
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
			sentence_id = line.split[0].to_i
			meaning_id = line.split[1].to_i
			@pairs << [sentence_id, meaning_id]
		end
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
			id = line.split[0].to_i
			lang = line.split[1]
			text = line.split[2]
			username = line.split[3]

			if lang == 'eng'
				@english[id] = text
				@usernames[id] = username
			elsif lang == 'jpn'
				@japanese[id] = text
				@usernames[id] = username
			end
		end
	end

	# Returns true iff the sentence is adopted.
	def adopted? id
		return @usernames.key? id
	end

	# Returns true iff the tags are all safe.
	def safe_tags? id
		# If there are no tags, it is safe.
		unless @tags.key? id
			return true
		end

		#TODO Add more tags here.
		dangerous = ['ambiguous']

		# Examine each tag.  If it's dangerous, return false.
		@tags[id].each do |tag|
			if dangerous.include? tag
				return false
			end
		end

		return true
	end
	
	# Makes notes for each of the Japanese/English sentence pairs.
	def make_notes
		notes = []

		@pairs.each do |pair|
			sentence_id = pair[0]
			meaning_id = pair[1]

			# Unadopted sentences aren't used.
			unless (adopted? sentence_id) and (adopted? meaning_id)
				next
			end

			# Only sentences with safe tags are used.
			unless (safe_tags? sentence_id) and (safe_tags? meaning_id)
				next
			end

			sentence = @japanese[sentence_id]
			meaning = @english[meaning_id]

			notes << Note.new(sentence, meaning)
		end

		@notes = notes
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

	# Writes a list of all the tags used.
	def show_all_tags
		tags = @tags.values
		tags.uniq!
		tags.sort!
		puts tags
	end
end

# Prints a list of notes.
def show_notes notes
	s = ''

	notes.each do |note|
		s += note.kanji + "\t" + note.kana + "\t" + note.english + "\n"
	end

	puts s
end

$corpus = Corpus.new
$corpus.show_all_tags
#show_notes $corpus.notes
