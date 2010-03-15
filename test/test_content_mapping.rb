
require 'helper'
require 'mocha'

class TestContentMapping < Test::Unit::TestCase

  context "on empty content mapping creation" do
    setup do
      @mapping = ContentMapping.new
      @mapping.instance_eval do
        url_pattern /^http:\/\/www\.matchme\.com\//
          content_at '//div[@id="failing_content"]'
        content_at '//div[@id="itext_content"]'
        content_at '//div[@id="itext_second_content"]'
      end
    end
    should "match the right urls" do
      assert @mapping.matches_url?('http://www.matchme.com/')
    end
    should "not match the wrong urls" do
      assert !@mapping.matches_url?('https://www.somethingelse.org/hfas')
    end
    context "scrapping content for a specific site" do
      setup do
        pretty_content = File.open("#{File.dirname(__FILE__)}/test_pages/pretty.html").read 
        @document = Nokogiri::HTML(pretty_content)
      end
      should "extract the content" do
        assert_match(%r{<p><strong>This is a strong text</strong></p>},
                     @mapping.scrap_content(@document))
      end
    end
    context "on document with two content parts" do
      setup do
        two_content = File.open("#{File.dirname(__FILE__)}/test_pages/twocontent.html").read 
        @document = Nokogiri::HTML(two_content)
      end
      should "evaluate the contents in the order as they were added" do
        assert_match(%r{The first one is matched}, @mapping.scrap_content(@document))
      end
    end
  end

  context "on url matcher definition using wildcards" do
    setup do
      @mapping = ContentMapping.new
      @mapping.instance_eval do
        url_pattern 'http://*.example.com/*'
      end
    end
    should "match urls with matching wildcards" do
      assert @mapping.matches_url?('http://test.example.com/path/to/doc.html')
    end
    should "not match urls with not matching wildcards" do
      assert !@mapping.matches_url?('http://test.example2.com/path/to/doc.html')
    end
  end

  context "on pattern for page for encoding" do
    setup do
      @mapping = ContentMapping.new
      @mapping.instance_eval do
        url_pattern /^http:\/\/www\.matchme\.com\//
          content_at '//div[@class="node node-story"]/div[@class="content"]/p'
        iconv :to => 'utf8', :from => 'latin1'
      end
      page = File.open("#{File.dirname(__FILE__)}/test_pages/encoding.html").read 
      @document = Nokogiri::HTML(page)
    end
    should "scrap a page with converted content" do
      @mapping.scrap_content(@document)
    end
  end
end
