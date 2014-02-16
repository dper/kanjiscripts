#!/usr/bin/ruby
# coding: utf-8
#
# == NAME
# kana.rb
#
# == USAGE
# ./kana.rb
#
# == DESCRIPTION
# A script that makes phonetic readings of Japanese sentences.
#
# == AUTHOR
# Douglas P Perkins - https://dperkins.org - https://microca.st/dper


ENV['MECAB_PATH']='/usr/lib/libmecab.so.2'
require 'natto'
require 'nkf'

def make_kana text
	nm = Natto::MeCab.new
	memo = []

	nm.parse(text) do |n|
		if n.char_type == 2
			yomi = n.feature.split(',')[-2]
			memo << NKF.nkf('-h1 -w', yomi)
		else
			memo << n.surface
		end
	end

	@kana = memo.join
end

def test
	sentences = ['彼は狂人のように振る舞った。', '私はアメリカ人です。']

	sentences.each do |sentence|
		puts 'Original: ' + sentence
		puts '--------> ' + (make_kana sentence)
	end
end

test
