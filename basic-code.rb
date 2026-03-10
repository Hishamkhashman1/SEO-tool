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

favicon = doc.at('link[rel="icon"]')&.[]('href') || doc.at('link[rel="shortcut icon"]')&.[]('href')
meta_desc = doc.at('meta[name="description"]')&.[]('content')
meta_desc_length = meta_desc.length if meta_desc
meta_keywords = doc.at('meta[name="keywords"]')&.[]('content')
author = doc.at('meta[name="author"]')&.[]('content')

h1_count = doc.css('h1').size
h2_count = doc.css('h2').size
h3_count = doc.css('h3').size
strong_count = doc.css('strong').count
em_count = doc.css('em').count

button_count = doc.css('button').count
form_count = doc.css('form').count
iframe_count = doc.css('iframe').count
inline_styles = doc.css('[style]').count

id_count = doc.css('[id]').count
class_count = doc.css('[class]').count

table_count = doc.css('table').count

ul_count = doc.css('ul').count
ol_count = doc.css('ol').count

p_count = doc.css('p').count

canonical = doc.at('link[rel="canonical"]')&.[]('href')

robots = doc.at('meta[name="robots"]')&.[]('content')

text = doc.text
words_count = text.length

total_images = doc.css('img').size
images_missing_alt = doc.css('img:not([alt])').count


internal_links = doc.css('a[href^="/"]').size
external_links = doc.css('a[href^="http"]').size
nofollow_links = doc.css('a[rel~="nofollow"]').count


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
puts "Favicon: #{favicon}"

puts "Meta description* #{meta_desc}"
puts "Meta desc. Length #{meta_desc_length}"
puts "Meta keywords: #{meta_keywords}"
puts "Author: #{author}"

puts "H1 count: #{h1_count}"
puts "Warning: Multiple H1 tags" if h1_count > 1
puts "H2 count: #{h2_count}"
puts "H3 count: #{h3_count}"
puts "Strong tags: #{strong_count}"
puts "EM tags: #{em_count}"

puts "Button count: #{button_count}"
puts "Forms count: #{form_count}"
puts "Iframes count: #{iframe_count}"
puts "Elements with inline style: #{inline_styles}"

puts "Elements with id: #{id_count}"
puts "Elements with class: #{class_count}"

puts "Tables count: #{table_count}"

puts "UL count: #{ul_count}"
puts "OL count: #{ol_count}"

puts "Paragraph count: #{p_count}"

puts "Canonical: #{canonical}"
puts "Robots meta: #{robots}"

puts "Word count: #{words_count}"

puts "Images missing #{images_missing_alt}"
puts "Total images: #{total_images}"

puts "Internal Links: #{internal_links}"
puts "External Links: #{external_links}"
puts "Nofollow links: #{nofollow_links}"

puts "OG title: #{og_title}"
puts "OG description: #{og_desc}"

puts "Page language: #{lang}"
puts "Viewport meta: #{viewport}"
puts "Empty links: #{empty_links}"
puts "Structured data blocks: #{schema}"
