# frozen_string_literal: true

class ApiI14ySearch < I14ySearch
  def initialize(options = {})
    super

    @highlight_options[:pre_tags] ||= Api::V2::HighlightOptions::DEFAULT[:pre_tags]
    @highlight_options[:post_tags] ||= Api::V2::HighlightOptions::DEFAULT[:post_tags]
  end
end
