
# getting input frmo user
print "Enter URL for SEO Check"

input = gets.chomp


# SEO very siimple analysis code
html = URI.open(input).read
doc = Nokogiri::HTML(html)
title = doc.at('title')&.text
meta_desc = doc.at('meta[name="description"]')&.[]('content')
h1_count = doc.css('h1').h1_count
images_missing_alt = doc.css('img::not([alt])').count


puts html
puts doc
puts title
puts meta_desc
puts h1_count
puts images_missing_alt
