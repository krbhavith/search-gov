# frozen_string_literal: true

class ImageResultsPostProcessor < ResultsPostProcessor
  include VisualDesignHelper

  def initialize(total_results, results, affiliate)
    super
    @total_results = total_results
    @results = results
    @affiliate = affiliate
  end

  def normalized_results
    {
      results: format_results,
      total: @total_results,
      totalPages: total_pages(@total_results),
      unboundedResults: false
    }
  end

  private

  def format_results
    @results&.map do |result|
      {
        altText: result['title'],
        url: result['url'],
        thumbnailUrl: result['thumbnail']['url'],
        image: show_image
      }.compact
    end
  end

  def show_image
    show_results_format?(@affiliate) ? @affiliate.display_image_on_search_results? : true
  end
end
