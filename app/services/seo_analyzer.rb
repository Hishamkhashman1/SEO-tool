require "open-uri"
require "nokogiri"

class SeoAnalyzer
  # Fetches a URL and returns a hash of SEO signals.
  def self.analyze(url)
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    title = doc.at("title")&.text
    title_size = title.length if title

    favicon = doc.at('link[rel="icon"]')&.[]("href") ||
              doc.at('link[rel="shortcut icon"]')&.[]("href")

    meta_desc = doc.at('meta[name="description"]')&.[]("content")
    meta_desc_length = meta_desc.length if meta_desc
    meta_keywords = doc.at('meta[name="keywords"]')&.[]("content")
    author = doc.at('meta[name="author"]')&.[]("content")

    h1_count = doc.css("h1").size
    h2_count = doc.css("h2").size
    h3_count = doc.css("h3").size
    strong_count = doc.css("strong").count
    em_count = doc.css("em").count

    button_count = doc.css("button").count
    form_count = doc.css("form").count
    iframe_count = doc.css("iframe").count
    inline_styles = doc.css("[style]").count

    id_count = doc.css("[id]").count
    class_count = doc.css("[class]").count

    table_count = doc.css("table").count

    ul_count = doc.css("ul").count
    ol_count = doc.css("ol").count

    p_count = doc.css("p").count

    canonical = doc.at('link[rel="canonical"]')&.[]("href")

    robots = doc.at('meta[name="robots"]')&.[]("content")

    text = doc.text
    words_count = text.length

    total_images = doc.css("img").size
    images_missing_alt = doc.css("img:not([alt])").count

    internal_links = doc.css('a[href^="/"]').size
    external_links = doc.css('a[href^="http"]').size
    nofollow_links = doc.css('a[rel~="nofollow"]').count

    # Open Graph tags used by social media
    og_title = doc.at('meta[property="og:title"]')&.[]("content")
    og_desc = doc.at('meta[property="og:description"]')&.[]("content")

    lang = doc.at("html")&.[]("lang")

    viewport = doc.at('meta[name="viewport"]')&.[]("content")
    empty_links = doc.css('a[href="#"]').size
    schema = doc.css('script[type="application/ld+json"]').size

    # Return results in a stable, beginner-friendly order
    {
      "Title" => title,
      "Title Length" => title_size,
      "Favicon" => favicon,
      "Meta description" => meta_desc,
      "Meta description length" => meta_desc_length,
      "Meta keywords" => meta_keywords,
      "Author" => author,
      "H1 count" => h1_count,
      "H2 count" => h2_count,
      "H3 count" => h3_count,
      "Strong tags" => strong_count,
      "EM tags" => em_count,
      "Button count" => button_count,
      "Forms count" => form_count,
      "Iframes count" => iframe_count,
      "Elements with inline style" => inline_styles,
      "Elements with id" => id_count,
      "Elements with class" => class_count,
      "Tables count" => table_count,
      "UL count" => ul_count,
      "OL count" => ol_count,
      "Paragraph count" => p_count,
      "Canonical" => canonical,
      "Robots meta" => robots,
      "Word count" => words_count,
      "Images missing alt" => images_missing_alt,
      "Total images" => total_images,
      "Internal links" => internal_links,
      "External links" => external_links,
      "Nofollow links" => nofollow_links,
      "OG title" => og_title,
      "OG description" => og_desc,
      "Page language" => lang,
      "Viewport meta" => viewport,
      "Empty links" => empty_links,
      "Structured data blocks" => schema
    }
  end
end
