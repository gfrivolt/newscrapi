
require 'helper'
require 'nokogiri'
require 'newscrapi/encoding'

class TestEncoding < Test::Unit::TestCase

  context "on guessing the encoding of a page with a metatag defined" do
    setup do
      @page = File.open("#{File.dirname(__FILE__)}/test_pages/windows-1250_page.html").read
      @doc = Nokogiri::HTML(@page)
    end
    should "detect the page encoding correctly for string input" do
      assert_equal 'windows-1250', Newscrapi::Encoding.guess_html_encoding(@page)
    end
    should "detect the page encoding correctly for parsed document input" do
      assert_equal 'windows-1250', Newscrapi::Encoding.guess_html_encoding(@doc)
    end
  end

  context "on guessing the encoding of a page without the encoding metatag defined" do
    setup do
      @page = File.open("#{File.dirname(__FILE__)}/test_pages/utf-8_page.html").read
      @doc = Nokogiri::HTML(@page)
    end
    should "detect the page encoding correctly for string input" do
      assert_equal 'utf-8', Newscrapi::Encoding.guess_html_encoding(@page)
    end
    should "detect the page encoding correctly for parsed document input" do
      assert_equal 'utf-8', Newscrapi::Encoding.guess_html_encoding(@doc)
    end
  end

  context "on not supported class type encoding guessing" do
    should "raise exception" do
      assert_raise Exception do
        Newscrapi::Encoding.guess_html_encoding(5)
      end
    end
  end

end

