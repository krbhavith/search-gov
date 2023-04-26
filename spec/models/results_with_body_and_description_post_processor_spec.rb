# frozen_string_literal: true

require 'spec_helper'

describe ResultsWithBodyAndDescriptionPostProcessor do
  describe '#normalized_results' do
    subject(:normalized_results) { described_class.new(results).normalized_results }

    let(:test_date) { DateTime.new(2001, 2, 3, 4, 5, 6) }
    let(:results) do
      results = []
      5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", description: "content #{index}", url: "http://foo.gov/#{index}") }
      results
    end

    it_behaves_like 'a search with normalized results' do
      let(:normalized_results) { described_class.new(results).normalized_results }
    end

    it 'has no published date, updated date, or thumbnaul URL' do
      normalized_results.each do |result|
        expect(result[:updatedDate]).to be_nil
        expect(result[:publishedDate]).to be_nil
        expect(result[:thumbnailUrl]).to be_nil
      end
    end
  end
end