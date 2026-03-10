require "uri"

class SeoReportsController < ApplicationController
  # Shows the form
  def index
    @url = params[:url]
  end

  # Processes the submitted URL and renders results
  def show
    @url = params[:url].to_s.strip

    if @url.empty?
      @error = "Please enter a URL."
      return render :index, status: :unprocessable_entity
    end

    begin
      uri = URI.parse(@url)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        raise URI::InvalidURIError
      end

      @results = SeoAnalyzer.analyze(@url)
      render :show
    rescue StandardError
      # Keep the message friendly and simple for beginners
      @error = "We couldn't fetch that page. Please check the URL and try again."
      render :index, status: :unprocessable_entity
    end
  end
end
