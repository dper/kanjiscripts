#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# make_pairs.rb
#
# == USAGE
# ./make_pairs.rb
#
# == DESCRIPTION
# A script that creates a list of English/Japanese sentence pairs.
# The base data should be downloaded from Tatoeba.
# Only sentences with safe-looking tags are included.
#
# This script depends on the files tags.csv and links.csv being in
# the tatoeba subdirectory.  Download them before use.  See the README
# for more information.
#
# == AUTHOR
# Douglas Perkins

Pairs = 'pairs.txt'
Tags = 'tags.csv'
Links = 'links.csv'
Sentences_detailed = 'sentences_detailed.csv'

# A note for a flash card containing a sentence in kanji and English.
class Note
	attr_accessor :kanji	# The kanji sentence.
	attr_accessor :english	# The English meaning of the sentence.

	# Creates a Note.
	def initialize(japanese, english)
		@kanji = String.new japanese
		@english = String.new english
	end
end

# A sentence pair maker.  This sorts and writes notes.
class PairMaker
	# Sort the notes from shortest to longest Japanese sentence.
	def sort_notes
		puts 'Sorting notes by sentence length ...'
		@notes.sort! do |note1, note2| note1.kanji.length <=> note2.kanji.length end	
	end

	# Creates a PairMaker
	def initialize notes
		@notes = Array.new notes
		sort_notes
	end

	# Prints a list of notes.
	def write_pairs
		puts 'Writing output to ' + Pairs + ' ...'

		open(Pairs, 'w') do |file|
			@notes.each do |note|
				s = note.kanji + "\t" + note.english
				file.puts s
			end
		end
	end
end

# Sentence corpus.
class Corpus
	attr_accessor :notes	# Notes for the Japanese/English sentence pairs.

	# Parses tags file.
	def parse_tags
		puts 'Parsing ' + Tags + ' ...'
		path = '../tatoeba/' + Tags
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

		puts 'Total tags: ' + @tags.size.to_s + '.'
	end

	# Parses the links file.
	def parse_links
		puts 'Parsing ' + Links + ' ...'
		path = '../tatoeba/' + Links
		text = IO.readlines path
		@links = []

		# The links file has lines like this: sentence_id [tab] translation_id.
		
		text.each do |line|
			sentence_id = line.split("\t")[0].to_i
			meaning_id = line.split("\t")[1].to_i
			@links << [sentence_id, meaning_id]
		end

		puts 'Unfiltered links: ' + @links.size.to_s + '.'
	end

	# Parses the corpus sentence file.	
	def parse_sentences
		puts 'Parsing ' + Sentences_detailed + ' ...'
		path = '../tatoeba/' + Sentences_detailed
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
			line.encode!('UTF-8', 'UTF-8', :invalid => :replace)
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

		puts 'Unfiltered English sentences: ' + @english.size.to_s + '.'
		puts 'Unfiltered Japanese sentences: ' + @japanese.size.to_s + '.'
	end

	# Makes pairs of Japanese/English sentences.
	def find_pairs
		puts 'Finding Japanese/English pairs ...'
		@pairs = []

		# For each pair, see if it's English to Japanese.
		# If so, add the ordered pair to the list.
		@links.each do |pair|
			sentence_id = pair[0]
			translation_id = pair[1]

			if (@english.key? sentence_id) and (@japanese.key? translation_id)
				@pairs << {"english_id" => sentence_id, "japanese_id" => translation_id}
			end
		end

		puts 'Unfiltered English/Japanese pairs: ' + @pairs.size.to_s + '.'
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

		# Only keep sentences with the 'OK' tag.
		#unless @tags[id].include? 'OK'
		#	return false
		#end

		# This list of prefixes of tags can be modified as desired.
		dangerous = ['@Check!', '@change', '@check', '@delete', '@duplicate', '@fragment', '@need native', '@needs', '@not a sentences', '@wrong', 'ambigous', 'ambiguos', 'ambiguous', 'baby talk', 'check eng']

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
		puts 'Making notes for sentence pairs ...'
		notes = []
		not_adopted = 0
		unsafe_tags = 0
		english_not_found = 0
		japanese_not_found = 0

		@pairs.each do |pair|
			english_id = pair["english_id"]
			japanese_id = pair["japanese_id"]

			# Unadopted sentences aren't used.
			unless (adopted? english_id) and (adopted? japanese_id)
				not_adopted += 1
				next
			end

			# Only sentences with safe tags are used.
			unless (safe_tags? english_id) and (safe_tags? japanese_id)
				unsafe_tags += 1
				next
			end

			japanese = @japanese[japanese_id]
			english = @english[english_id]

			unless english
				english_not_found += 1
				puts 'Warning: English sentence ' + english_id.to_s + ' not found.  Skipping.'
				next
			end

			unless japanese
				japanese_not_found += 1
				puts 'Warning: Japanese sentence ' + japanese_id.to_s + ' not found.  Skipping.'
				next
			end

			notes << Note.new(japanese, english)
		end

		@notes = notes
		puts 'Not adopted pairs: ' + not_adopted.to_s + '.'
		puts 'Unsafe tags pairs: ' + unsafe_tags.to_s + '.'
		puts 'English sentence not found: ' + english_not_found.to_s + '.'
		puts 'Japanese sentence not found: ' + japanese_not_found.to_s + '.'
		puts 'English/Japanese notes: ' + notes.size.to_s + '.'
	end

	# Creates a Corpus.
	def initialize
		parse_tags
		parse_links
		parse_sentences	
		find_pairs
		make_notes
	end
end

$corpus = Corpus.new
$pairmaker = PairMaker.new $corpus.notes
$pairmaker.write_pairs
