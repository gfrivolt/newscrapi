
require 'helper'
require 'mocha'

class TestPages < Test::Unit::TestCase

  context "on page containing CDATA" do
    setup do
      @scrapper = Newscrapi::Scrapper.new
      @scrapper.instance_eval do
        content_mapping do
          url_pattern /.*/
          content_at '//div[@class="art-full adwords-text"]'
        end
        loofah_tags(:strip)
      end
      @scrapper.rescue_scrapping do |exception,url|
        puts exception
      end
      cdata_content = File.open("#{File.dirname(__FILE__)}/test_pages/cdata.html").read
      Kernel.expects(:open).returns(StringIO.new(cdata_content))
    end
    should "not escape the cdata entries, should leave cdata unvisible" do
      assert_match /<!--</, @scrapper.scrap_content('http://www.cdata.url/hsdae')
    end
  end

  context "on page encoding conversion" do
    setup do
      @scrapper = Newscrapi::Scrapper.new
      @scrapper.instance_eval do
        encode_to 'utf-8'
        content_mapping do
          url_pattern /.*/
            content_at '//div[@id="itext_content"]'
        end
      end
      content = File.open("#{File.dirname(__FILE__)}/test_pages/windows-1250_page.html").read
      Kernel.expects(:open).returns(StringIO.new(content))
    end
    should "convert the document to utf-8 encoding" do
      require 'rchardet'
      scrapped_page = @scrapper.scrap_content('http://hop.kop')
      assert_equal 'utf-8', CharDet.detect(scrapped_page)['encoding']
    end
  end

=begin
  context "on pattern for page for encoding" do
    setup do
      @scrapper = Newscrapi::Scrapper.new
      @scrapper.instance_eval do
        encode_to 'windows-1250'
        content_mapping do
          url_pattern /^http:\/\/www\.matchme\.com\//
            content_at '//div[@class="node node-story"]/div[@class="content"]/p'
          suppose_encoding 'utf-8'
        end
      end
      CharDet.expects(:detect).never
      @page = File.open("#{File.dirname(__FILE__)}/test_pages/page_without_encoding_meta_tag.html").read
    end
    should "scrap a page with converted content" do
      assert_not_nil @scrapper.scrap_content('http://www.matchme.com', @page)
    end
  end
=end
end

