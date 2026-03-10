# SEO Tool (Rails)

A simple Ruby on Rails web app that checks basic SEO signals for a given URL.


## Features
- One-page form to enter a URL
- Displays SEO signals in grouped sections


## Requirements
- Ruby 3.3.5
- Rails 7.1.x

## Setup
```bash
bundle install
```

## Run locally
```bash
bundle exec rails s
```
Open `http://localhost:3000` in your browser.

## Notes
- SEO parsing uses `open-uri` and `nokogiri`.
