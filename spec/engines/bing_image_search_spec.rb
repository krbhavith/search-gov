# coding: utf-8
require 'spec_helper'

describe BingImageSearch do

  context 'when results are available' do
    let(:image_search) { BingImageSearch.new(query: "white house", enable_highlighting: true) }

    it "should return a response" do
      normalized_response = image_search.execute_query
      normalized_response.start_record.should == 1
      normalized_response.end_record.should == 10
      normalized_response.total.should == 4340000
      first = normalized_response.results.first
      first.title.should == "White House, Washington D.C."
      first.width.should == 391
      first.height.should == 428
      first.file_size.should == 37731
      first.content_type.should == 'image/jpeg'
      first.url.should == 'http://biglizards.net/blog/archives/2008/08/'
      first.display_url.should == 'http://biglizards.net/blog/archives/2008/08/'
      first.media_url.should == 'http://biglizards.net/Graphics/ForegroundPix/White_House.JPG'
      thumbnail = first.thumbnail
      thumbnail.url.should == 'http://ts1.mm.bing.net/images/thumbnail.aspx?q=1581721453740&id=869b85a01b58c5a200496285e0144df1'
      thumbnail.height.should == 160
      thumbnail.width.should == 146
    end
  end

end