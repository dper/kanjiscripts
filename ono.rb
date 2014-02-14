#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# ono.rb
#
# == USAGE
# ./ono.rb
#
# == DESCRIPTION
# A script that does things with onomatopoeic words in Japanese.
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

# Looks up words in Edict.
class Edict
	# Creates an Edict.  Parsing the edict file takes a long time,
	# so it is desirable to only make one of this.
	def initialize
		verbose 'Parsing edict.txt ...'
		path = Script_dir + '/edict.txt'
		edict = IO.readlines path
		@lookup_table = {}
		
		edict.each do |line|
			# Lines with definitions start with the word, followed
			# by a blank line, followed by the definition.  If
			# there is more than one definition, the first one is
			# used.
			next unless line.include? " "
			word, blank, definition = line.partition " "
			next if @lookup_table.key? word
			@lookup_table[word] = definition
		end
	end

	# Looks up a word, returning its kana and definition.  Returns nil iff
	# the word is not in the dictionary.
	def define word
		# Definitions are stored in @lookup_table, which is indexed by
		# the words.  The definition starts with the reading in
		# parentheses, followed by one or more definitions, as well as
		# grammatical terms.  Only the first definition is used here.
		definition = @lookup_table[word]
		if not definition then return nil end
		kana = definition.partition('[')[2].partition(']')[0]
		meaning = definition.partition('/')[2]
		meaning = meaning.partition('/')[0].lstrip
		while meaning.start_with? '('
			meaning = meaning.partition(')')[2].lstrip
		end

		meaning = $styler.fix_style meaning
		return [kana, meaning]
	end

	# Creates a list of all the onomotopoaeic words in edict.
	def find_ono_words
		verbose 'Finding the onomotopaeic words in edict ...'

		ono_words = []

		@lookup_table.each do |word, definition|
			meaning = definition.partition('/')[2]
			if meaning.include? '(on-mim)'
				ono_words << word
			end
		end

		@ono_words = ono_words
	end

	# Returns a list of all the onomotopoaeic words in edict.
	def get_ono_words
		unless @ono_words
			find_ono_words
		end

		return @ono_words
	end
end

$edict = Edict.new
words = $edict.get_ono_words
verbose words

#TODO Sort the list by word frequency.
