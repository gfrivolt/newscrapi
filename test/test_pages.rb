
require 'helper'
require 'mocha'

class TestContentScrapper < Test::Unit::TestCase

  context "on page containing CDATA" do
    setup do
      @scrapper = ContentScrapper.new
      @scrapper.instance_eval do
        content_mapping do
          url_pattern /.*/
          content_at '//div[@class="art-full adwords-text"]'
        end
        loofah_tags(:strip)
      end
      @scrapper.rescue_scrapping do |exception|
        puts exception
      end
      cdata_content = File.open("#{File.dirname(__FILE__)}/test_pages/cdata.html").read
      Kernel.expects(:open).returns(StringIO.new(cdata_content))
    end
    should "not escape the cdata entries, should leave cdata unvisible" do
      #<!--<![CDATA[
      assert_match /<!--</, @scrapper.scrap_content('http://www.cdata.url/hsdae')
    end
  end
end

