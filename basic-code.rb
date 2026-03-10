require 'nokogiri'
require 'open-uri'

# getting input frmo user
print "Enter URL for SEO Check"

input = gets.chomp


# SEO very siimple analysis code
html = URI.open(input).read

doc = Nokogiri::HTML(html)
title = doc.at('title')&.text
title_size = title.length if title

meta_desc = doc.at('meta[name="description"]')&.[]('content')
meta_desc_length = meta_desc.length if meta_desc


h1_count = doc.css('h1').size
h2_count = doc.css('h2').size
h3_count = doc.css('h3').size

canonical = doc.at('link[rel="canonical"]')&.[]('href')

robots = doc.at('meta[name="robots"]')&.[]('content')

text = doc.text
words_count = text.length

total_images = doc.css('img').size
images_missing_alt = doc.css('img:not([alt])').count


internal_links = doc.css('a[href^="/"]').size

external_links = doc.css('a[href^="http"]').size

#Open Graph tags used by Social Media
og_title = doc.at('meta[property="og:title"]')&.[]('content')
og_desc = doc.at('meta[property="og:description"]')&.[]('content')

lang = doc.at('html')&.[]('lang')

viewport = doc.at('meta[name="viewport"]')&.[]('content')
empty_links = doc.css('a[href="#"]').size
schema = doc.css('script[type="application/ld+json"]').size

#structured data blocks goes here

puts "Title: #{title}"
puts "Title Length: #{title_size}"

puts "Meta description* #{meta_desc}"
puts "Meta desc. Length #{meta_desc_length}"

puts "H1 count: #{h1_count}"
puts "Warning: Multiple H1 tags" if h1_count > 1
puts "H2 count: #{h2_count}"
puts "H3 count: #{h3_count}"

puts "Canonical: #{canonical}"
puts "Robots meta: #{robots}"

puts "Word count: #{words_count}"

puts "Images missing #{images_missing_alt}"
puts "Total images: #{total_images}"

puts "Internal Links: #{internal_links}"
puts "External Links: #{external_links}"

puts "OG title: #{og_title}"
puts "OG description: #{og_desc}"

puts "Page language: #{lang}"
puts "Viewport meta: #{viewport}"
puts "Empty links: #{empty_links}"
puts "Structured data blocks: #{schema}"
