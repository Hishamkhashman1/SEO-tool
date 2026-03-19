module SeoReportsHelper
  def seo_score_payload(results)
    return {} if results.blank?

    metrics = extract_metrics(results)
    categories = build_categories(metrics)
    overall = (categories.sum { |cat| cat[:score] } / categories.size.to_f).round

    {
      score: overall,
      rank: rank_for(overall),
      summary: summary_for(categories, overall),
      roast_summary: roast_summary_for(categories, overall),
      categories: categories,
      badges: build_badges(metrics),
      highlights: build_highlights(metrics, roast: false),
      roast_highlights: build_highlights(metrics, roast: true)
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
      badge("Title Pulse", "Title length in the optimal zone.",
        "Unlock by tuning the title length.", metrics[:title_present] && metrics[:title_length].between?(30, 65)),
      badge("Meta Magnet", "Meta description tuned for previews.",
        "Unlock by adding a meta description.", metrics[:meta_desc_present] && metrics[:meta_desc_length].between?(70, 160)),
      badge("Structure Prime", "H1 + H2 hierarchy detected.",
        "Unlock by adding an H1 and H2.", metrics[:h1] == 1 && metrics[:h2] >= 1),
      badge("Alt Guardian", "Every image ships with alt text.",
        "Unlock by fixing image alt coverage.", metrics[:total_images] > 0 && metrics[:images_missing_alt] == 0),
      badge("Schema Spark", "Structured data detected.",
        "Unlock by adding structured data.", metrics[:structured_data] > 0),
      badge("Link Architect", "Healthy internal/external balance.",
        "Unlock by strengthening internal and external links.", metrics[:internal_links] >= 5 && metrics[:external_links] >= 1),
      badge("Social Surge", "Open Graph tags are complete.",
        "Unlock by adding OG title and description.", metrics[:og_title_present] && metrics[:og_desc_present]),
      badge("Viewport Pilot", "Mobile viewport configured.",
        "Unlock by adding a viewport meta tag.", metrics[:viewport_present])
    ]
  end

  def build_highlights(metrics, roast: false)
    issues = []
    positives = []

    if roast
      issues << "Your site is hiding its brain - no structured data detected." if metrics[:structured_data] == 0
      issues << "No H1 found. The page forgot its name tag." if metrics[:h1] == 0
      issues << "Meta description is missing. Search previews are running on vibes." unless metrics[:meta_desc_present]
      issues << "Images missing alt: #{metrics[:images_missing_alt]}. Vision is not optional." if metrics[:images_missing_alt] > 0
      issues << "Open Graph tags are sleeping. Social previews look blank." unless metrics[:og_title_present] || metrics[:og_desc_present]
      issues << "Empty links detected: #{metrics[:empty_links]}. Dead ends everywhere." if metrics[:empty_links] > 0

      positives << "Identity confirmed - title tag locked in." if metrics[:title_present]
      positives << "Canonical is set. Duplicate chaos avoided." if metrics[:canonical_present]
      positives << "Structured data online. The bots can read your mind." if metrics[:structured_data] > 0
      positives << "Social tags complete. Previews are battle-ready." if metrics[:og_title_present] && metrics[:og_desc_present]
    else
      issues << "Your site is hiding its brain - no structured data detected." if metrics[:structured_data] == 0
      issues << "No H1 heading detected. Give the page a primary headline." if metrics[:h1] == 0
      issues << "Meta description missing. Add one for sharper previews." unless metrics[:meta_desc_present]
      issues << "Images missing alt: #{metrics[:images_missing_alt]}. Describe those visuals." if metrics[:images_missing_alt] > 0
      issues << "Open Graph tags missing. Social previews are blind." unless metrics[:og_title_present] || metrics[:og_desc_present]
      issues << "Empty links detected: #{metrics[:empty_links]}. Clean up dead ends." if metrics[:empty_links] > 0

      positives << "Identity confirmed - title tag locked in." if metrics[:title_present]
      positives << "Canonical tag active. Duplicates stay in check." if metrics[:canonical_present]
      positives << "Structured data detected. Machines can parse you." if metrics[:structured_data] > 0
      positives << "Social tags complete. Previews are ready." if metrics[:og_title_present] && metrics[:og_desc_present]
    end

    (issues + positives).first(4)
  end

  def summary_for(categories, overall)
    return "Signal capture complete." if categories.empty?

    strongest, weakest = strongest_and_weakest(categories)
    if overall >= 85
      "Strong signal overall. #{weakest[:name]} still needs tuning."
    elsif overall >= 70
      "Momentum is building. #{strongest[:name]} is leading, #{weakest[:name]} needs backup."
    else
      "Low signal stability. #{strongest[:name]} holds the line while #{weakest[:name]} drifts."
    end
  end

  def roast_summary_for(categories, overall)
    return "Signal capture complete." if categories.empty?

    strongest, weakest = strongest_and_weakest(categories)
    if overall >= 85
      "Nice work. #{weakest[:name]} is the last boss."
    elsif overall >= 70
      "You are halfway to elite. #{strongest[:name]} is saving you, #{weakest[:name]} is not."
    else
      "Rough landing. #{strongest[:name]} survived, #{weakest[:name]} did not."
    end
  end

  def rank_for(score)
    case score
    when 95..100
      "Google Whisperer"
    when 80..94
      "Circuit Elite"
    when 60..79
      "Signal Rising"
    when 40..59
      "Barely Indexed"
    else
      "Dead Site"
    end
  end

  def badge(name, description, hint, unlocked)
    {
      name: name,
      description: description,
      hint: hint,
      unlocked: unlocked
    }
  end

  def metadata_hint(metrics)
    return "Title and meta description are broadcasting." if metrics[:title_present] && metrics[:meta_desc_present]
    "Metadata coverage is thin. Boost your signals."
  end

  def content_hint(metrics)
    return "Headings and content volume look healthy." if metrics[:h1] >= 1 && metrics[:paragraphs] >= 3
    "Content depth is light. Add more structure and text."
  end

  def technical_hint(metrics)
    return "Technical signals are stable." if metrics[:structured_data] > 0 && metrics[:empty_links] == 0
    "Technical layer needs cleanup."
  end

  def link_hint(metrics)
    return "Internal and external links are alive." if metrics[:internal_links] >= 3 && metrics[:external_links] >= 1
    "Link graph is light. Add more paths."
  end

  def social_hint(metrics)
    return "Open Graph tags ready." if metrics[:og_title_present] && metrics[:og_desc_present]
    "Social previews are dark. Add OG tags."
  end

  def clamp_score(score)
    [[score, 0].max, 100].min
  end

  def strongest_and_weakest(categories)
    sorted = categories.sort_by { |cat| cat[:score] }
    [sorted.last, sorted.first]
  end
end
