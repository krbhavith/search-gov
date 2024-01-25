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
        image: true
      }.compact
    end
  end
end
