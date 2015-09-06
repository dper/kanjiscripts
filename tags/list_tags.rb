#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# list_tags.rb
#
# == USAGE
# ./list_tags.rb
#
# == DESCRIPTION
# A script that lists all tags used in the Corpus.
#
# This script depends on several files having proper formatting located
# in the same directory. See the README for file source information.
#
# == AUTHOR
# Douglas P Perkins - https://dperkins.org - https://microca.st/dper

Script_dir = File.dirname(__FILE__)

def read_tags
	path = Script_dir + '/../tatoeba/tags.csv'
	text = IO.readlines path
	tags = []

	text.each do |line|
		tags << line.split("\t")[1]
	end

	tags.uniq!
	tags.sort!
	return tags
end

puts read_tags
