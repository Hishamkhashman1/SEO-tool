require 'nokogiri'
require 'open-uri'

# getting input frmo user
print "Enter URL for SEO Check"

input = gets.chomp


# SEO very siimple analysis code
html = URI.open(input).read

doc = Nokogiri::HTML(html)
title = doc.at('title')&.text
meta_desc = doc.at('meta[name="description"]')&.[]('content')
h1_count = doc.css('h1').size
images_missing_alt = doc.css('img:not([alt])').count


puts "Title: #{title}"
puts "Meta description* #{meta_desc}"
puts "H1 count: #{h1_count}"
puts "Images missing #{images_missing_alt}"
