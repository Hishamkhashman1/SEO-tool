module SeoReportsHelper
  def seo_score_payload(results)
    return {} if results.blank?

    metrics = extract_metrics(results)
    categories = build_categories(metrics)
    overall = (categories.sum { |cat| cat[:score] } / categories.size.to_f).round

    {
      score: overall,
      tier: tier_for(overall),
      summary: summary_for(categories),
      categories: categories,
      badges: build_badges(metrics),
      highlights: build_highlights(metrics)
    }
  end

  private

  def extract_metrics(results)
    {
      title_present: results["Title"].present?,
      title_length: results["Title Length"].to_i,
      meta_desc_present: results["Meta description"].present?,
      meta_desc_length: results["Meta description length"].to_i,
      canonical_present: results["Canonical"].present?,
      robots_present: results["Robots meta"].present?,
      viewport_present: results["Viewport meta"].present?,
      language_present: results["Page language"].present?,
      favicon_present: results["Favicon"].present?,
      og_title_present: results["OG title"].present?,
      og_desc_present: results["OG description"].present?,
      h1: results["H1 count"].to_i,
      h2: results["H2 count"].to_i,
      h3: results["H3 count"].to_i,
      paragraphs: results["Paragraph count"].to_i,
      word_count: results["Word count"].to_i,
      strong_tags: results["Strong tags"].to_i,
      em_tags: results["EM tags"].to_i,
      ul: results["UL count"].to_i,
      ol: results["OL count"].to_i,
      tables: results["Tables count"].to_i,
      total_images: results["Total images"].to_i,
      images_missing_alt: results["Images missing alt"].to_i,
      empty_links: results["Empty links"].to_i,
      inline_styles: results["Elements with inline style"].to_i,
      iframes: results["Iframes count"].to_i,
      forms: results["Forms count"].to_i,
      buttons: results["Button count"].to_i,
      structured_data: results["Structured data blocks"].to_i,
      internal_links: results["Internal links"].to_i,
      external_links: results["External links"].to_i,
      nofollow_links: results["Nofollow links"].to_i
    }
  end

  def build_categories(metrics)
    metadata_score = 0
    metadata_score += 20 if metrics[:title_present]
    metadata_score += 10 if metrics[:title_length].between?(30, 65)
    metadata_score += 20 if metrics[:meta_desc_present]
    metadata_score += 10 if metrics[:meta_desc_length].between?(70, 160)
    metadata_score += 10 if metrics[:canonical_present]
    metadata_score += 5 if metrics[:robots_present]
    metadata_score += 10 if metrics[:viewport_present]
    metadata_score += 10 if metrics[:language_present]
    metadata_score += 5 if metrics[:favicon_present]

    content_score = 0
    content_score += 20 if metrics[:h1] >= 1
    content_score += 10 if metrics[:h2] >= 1
    content_score += 5 if metrics[:h3] >= 1
    content_score += 15 if metrics[:paragraphs] >= 3
    content_score += 20 if metrics[:word_count] >= 1000
    content_score += 10 if metrics[:strong_tags] + metrics[:em_tags] >= 3
    content_score += 10 if metrics[:ul] + metrics[:ol] + metrics[:tables] >= 1
    content_score += 10 if metrics[:total_images] >= 1

    technical_score = 0
    technical_score += 10 if metrics[:viewport_present]
    technical_score += 20 if metrics[:structured_data] > 0
    if metrics[:total_images] > 0
      technical_score += 20 if metrics[:images_missing_alt] == 0
    else
      technical_score += 10
    end
    technical_score += 10 if metrics[:empty_links] == 0
    technical_score += 10 if metrics[:inline_styles] <= 5
    technical_score += 10 if metrics[:iframes] == 0
    technical_score += 5 if metrics[:forms] <= 2
    technical_score += 5 if metrics[:buttons] <= 5
    technical_score += 10 if metrics[:robots_present]

    link_score = 0
    total_links = metrics[:internal_links] + metrics[:external_links]
    link_score += 40 if metrics[:internal_links] >= 3
    link_score += 20 if metrics[:external_links] >= 1
    link_score += 20 if total_links >= 5
    link_score += 20 if metrics[:nofollow_links] <= metrics[:external_links]

    social_score = 0
    social_score += 50 if metrics[:og_title_present]
    social_score += 50 if metrics[:og_desc_present]

    [
      {
        name: "Metadata",
        score: clamp_score(metadata_score),
        hint: metadata_hint(metrics)
      },
      {
        name: "Content",
        score: clamp_score(content_score),
        hint: content_hint(metrics)
      },
      {
        name: "Technical",
        score: clamp_score(technical_score),
        hint: technical_hint(metrics)
      },
      {
        name: "Links",
        score: clamp_score(link_score),
        hint: link_hint(metrics)
      },
      {
        name: "Social",
        score: clamp_score(social_score),
        hint: social_hint(metrics)
      }
    ]
  end

  def build_badges(metrics)
    [
      badge("Title Pulse", "Title length in the optimal zone.", metrics[:title_present] && metrics[:title_length].between?(30, 65)),
      badge("Meta Magnet", "Meta description tuned for previews.", metrics[:meta_desc_present] && metrics[:meta_desc_length].between?(70, 160)),
      badge("Structure Prime", "H1 + H2 hierarchy detected.", metrics[:h1] == 1 && metrics[:h2] >= 1),
      badge("Alt Guardian", "Every image ships with alt text.", metrics[:total_images] > 0 && metrics[:images_missing_alt] == 0),
      badge("Schema Spark", "Structured data detected.", metrics[:structured_data] > 0),
      badge("Link Architect", "Healthy internal/external balance.", metrics[:internal_links] >= 5 && metrics[:external_links] >= 1),
      badge("Social Surge", "Open Graph tags are complete.", metrics[:og_title_present] && metrics[:og_desc_present]),
      badge("Viewport Pilot", "Mobile viewport configured.", metrics[:viewport_present])
    ]
  end

  def build_highlights(metrics)
    issues = []
    issues << "Meta description missing." unless metrics[:meta_desc_present]
    issues << "No H1 heading detected." if metrics[:h1] == 0
    issues << "Images missing alt: #{metrics[:images_missing_alt]}." if metrics[:images_missing_alt] > 0
    issues << "No Open Graph preview tags." unless metrics[:og_title_present] || metrics[:og_desc_present]
    issues << "Structured data not detected." if metrics[:structured_data] == 0
    issues << "Empty links detected: #{metrics[:empty_links]}." if metrics[:empty_links] > 0

    positives = []
    positives << "Title tag detected." if metrics[:title_present]
    positives << "Canonical tag detected." if metrics[:canonical_present]
    positives << "Structured data present." if metrics[:structured_data] > 0
    positives << "Social tags complete." if metrics[:og_title_present] && metrics[:og_desc_present]

    (issues + positives).first(4)
  end

  def summary_for(categories)
    return "Signal capture complete." if categories.empty?

    sorted = categories.sort_by { |cat| cat[:score] }
    lowest = sorted.first
    highest = sorted.last
    "Strongest signal: #{highest[:name]}. Needs attention: #{lowest[:name]}."
  end

  def tier_for(score)
    case score
    when 90..100
      "Neon Vanguard"
    when 80..89
      "Circuit Elite"
    when 70..79
      "Signal Adept"
    when 60..69
      "Grid Runner"
    else
      "Noise Initiate"
    end
  end

  def badge(name, description, unlocked)
    {
      name: name,
      description: description,
      unlocked: unlocked
    }
  end

  def metadata_hint(metrics)
    return "Title + meta description active." if metrics[:title_present] && metrics[:meta_desc_present]
    "Metadata coverage needs attention."
  end

  def content_hint(metrics)
    return "Headings and content volume look healthy." if metrics[:h1] >= 1 && metrics[:paragraphs] >= 3
    "Boost headings or text volume."
  end

  def technical_hint(metrics)
    return "Technical signals are stable." if metrics[:structured_data] > 0 && metrics[:empty_links] == 0
    "Tighten technical hygiene."
  end

  def link_hint(metrics)
    return "Internal and external links active." if metrics[:internal_links] >= 3 && metrics[:external_links] >= 1
    "Link graph is light."
  end

  def social_hint(metrics)
    return "Open Graph tags ready." if metrics[:og_title_present] && metrics[:og_desc_present]
    "Add Open Graph previews."
  end

  def clamp_score(score)
    [[score, 0].max, 100].min
  end
end
