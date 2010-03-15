require 'helper'
require 'mocha'

class TestContentScrapper < Test::Unit::TestCase

  ContentScrapper.default_config_file = nil

  context "on settings without sanitization tags" do
    setup do
      @scrapper = ContentScrapper.new
      @scrapper.instance_eval do
        content_mapping do
          url_pattern /.*/
          content_at '//div[@id="itext_content"]'
        end
      end
      content = File.open("#{File.dirname(__FILE__)}/test_pages/pretty.html").read 
      stringio = StringIO.new(content)
      Kernel.expects(:open).returns(stringio)
    end
    should 'not sanitize' do
      assert !@scrapper.scrap_content('http://www.pretty.url/fsdsd').nil?
    end
  end

  context "on common settings" do
    setup do
      @scrapper = ContentScrapper.new
      @scrapper.instance_eval do
        content_mapping do
          url_pattern /^http:\/\/www\.pretty\.url/
          content_at '//div[@id="failing_content"]'
          content_at '//div[@id="itext_content"]'
        end

        content_mapping do
          url_pattern /^http:\/\/www\.twopatterns\.url/
          content_at '//div[@id="failing_content"]'
          content_at '//div[@id="itext_content"]'
        end

        content_mapping do
          url_pattern /^http:\/\/www\.twopatterns\.url/
          content_at '//div[@id="itext_second_content"]'
        end

        content_mapping do
          url_pattern /^http:\/\/www\.skipper\.url/
        end

        content_mapping do
          url_pattern /^http:\/\/www\.skipper\.url/
          content_at '//div[@id="never_should_be_here"]'
        end

        sanitize_tags do
          {:elements => ['p','br', 'b', 'em', 'i', 'strong', 'u', 'a', 'h1', 'h2', 'h3', 'li', 'ol', 'ul'], \
                       :attributes => { 'a' => ['href'] }}
        end

        for_testing_report_to_stderr
      end
    end

    should "identify the correct content mapper" do
      content_mapper = @scrapper.matching_content_mapper('http://www.pretty.url/fsdsd')
      assert !content_mapper.nil?
      assert_equal /^http:\/\/www\.pretty\.url/, content_mapper.url_pattern_regexp
    end

    context "for known sources with expected content scrapping" do
      setup do
        pretty_content = File.open("#{File.dirname(__FILE__)}/test_pages/pretty.html").read 
        stringio = StringIO.new(pretty_content)
        Kernel.expects(:open).returns(stringio)
        @entry_content = @scrapper.scrap_content('http://www.pretty.url/fsdsd')
      end
      should("identify the content") do
        assert_match(%r{<p><strong>This is a strong text</strong></p>}, @entry_content)
      end
    end

    context "for known pages with unexpected content scrapping" do
      setup do
        ugly_content = File.open("#{File.dirname(__FILE__)}/test_pages/ugly.html").read
        stringio = StringIO.new(ugly_content)
        Kernel.expects(:open).returns(stringio)
        @entry_content = @scrapper.scrap_content('http://www.pretty.url/hsdae')
      end
      should("return nil") { assert_nil @entry_content }
    end

    context "for unknown pages" do
      setup { @entry_content = @scrapper.scrap_content('http://www.unknown.url/hsdae') }
      should("return nil") { assert_nil @entry_content }
    end

    context "multiple matching url patterns" do
      setup do
        twocontent = File.open("#{File.dirname(__FILE__)}/test_pages/twocontent.html").read
        stringio = StringIO.new(twocontent)
        Kernel.expects(:open).with('http://www.twopatterns.url').returns(stringio)
        @entry_content = @scrapper.scrap_content('http://www.twopatterns.url')
      end
      should "match the first content" do
        assert_equal 'The first one is matched', @entry_content
      end
    end

    context "skipper patterns" do
      setup do
        Kernel.expects(:open).with('http://www.skipper.url/fdgsw').never
        @entry_content = @scrapper.scrap_content('http://www.skipper.url/fdgsw')
      end
      should("not match enything") { assert_nil @entry_content }
    end

    context "on already downloaded document" do
      setup do
        pretty_content = File.open("#{File.dirname(__FILE__)}/test_pages/pretty.html").read 
        Kernel.expects(:open).never
        @scrapped_content = @scrapper.scrap_content('http://www.pretty.url/hsdae',
                                                    :use_page => pretty_content)
      end
      should "scrap from the provided full page" do
        assert_match(%r{<p><strong>This is a strong text</strong></p>}, @scrapped_content)
      end
    end

    context "on scrapping with feedzirra" do
      setup do
        require 'content_scrapper/feedzirra'
        require 'sax-machine'
        require 'feedzirra/parser/rss_entry'
        require 'feedzirra/parser/atom_entry'
      end

      context "feed entry with not parsable remote content, but with feed content set" do
        setup do
          @feed_entries = [ Feedzirra::Parser::RSSEntry.new, Feedzirra::Parser::AtomEntry.new ]
          @feed_entries.each do |feed_entry|
            feed_entry.url = 'http://www.unknown.url/wedhsf'
            feed_entry.content = 'Pretty well written content is this.'
          end
          Kernel.expects(:open).with('http://www.unknown.url/wedhsf').never
        end
        should("return the original feed content") do
          @feed_entries.each do |feed_entry|
            assert_equal 'Pretty well written content is this.', feed_entry.scrap_content(@scrapper)
            feed_entry.scrap_content!(@scrapper)
            assert_equal 'Pretty well written content is this.', feed_entry.content
          end
        end
      end

      context "on feed entry with url and scrapping with full_page" do
        setup do
          @feed_entries = [ Feedzirra::Parser::RSSEntry.new, Feedzirra::Parser::AtomEntry.new ]
          @feed_entries.each do |feed_entry|
            feed_entry.url = 'http://www.pretty.url/wedhsf'
          end
          @pretty_content = File.open("#{File.dirname(__FILE__)}/test_pages/pretty.html").read
          Kernel.expects(:open).never
        end
        should("return the original feed content") do
          @feed_entries.each do |feed_entry|
            assert_match(%r{<p><strong>This is a strong text</strong></p>},
              feed_entry.scrap_content(@scrapper, :use_page => @pretty_content))
            feed_entry.scrap_content!(@scrapper, :use_page => @pretty_content)
            assert_match(%r{<p><strong>This is a strong text</strong></p>}, feed_entry.content)
          end
        end
      end
    end

    context "on failing scrapping" do
      setup do
        Kernel.expects(:open).raises(Exception, 'something failed')
        @exception_handle_flag = nil
        @scrapper.rescue_scrapping do |exception, url|
          @exception_handle_flag = exception.message
          @exception_url = url
        end
      end
      should "catch the exception and handle it" do
        assert_nil @scrapper.scrap_content('http://www.pretty.url')
        assert_equal 'something failed', @exception_handle_flag
        assert_equal 'http://www.pretty.url', @exception_url
      end
    end

    context "on missing url matcher" do
      setup do
        Kernel.expects(:open).never
        @missing_url_matcher_flag = nil
        @scrapper.missing_url_matcher do |url|
          @missing_url_matcher_flag = url
        end
        @scrapper.scrap_content('http://missing.url.matcher')
      end
      should "call the handler block" do
        assert_equal 'http://missing.url.matcher', @missing_url_matcher_flag
      end
    end

    context "on matching content mapper finding empty content" do
      setup do
        twocontent = File.open("#{File.dirname(__FILE__)}/test_pages/pretty_missing_content.html").read
        stringio = StringIO.new(twocontent)
        Kernel.expects(:open).with('http://www.pretty.url').returns(stringio)
        @missing_content_flag = 0
        @scrapper.missing_content do |url|
          @missing_content_flag += 1
        end
        @scrapper.scrap_content('http://www.pretty.url')
      end
      should "call the handler block only once" do
        assert_equal 1, @missing_content_flag
      end
    end
  end

  context "on setting default content scrapper" do
    setup { @scrapper = ContentScrapper.create_new_default }
    should "set the default to the recently created" do
      assert_equal @scrapper, ContentScrapper.default
    end
    context "when changing default content scrapper" do
      setup { @new_scrapper = ContentScrapper.new.set_as_default }
      should "change the default to the new content scrapper" do
        assert_equal @new_scrapper, ContentScrapper.default
      end
    end

    context "for feed entry" do
      setup do
        @feed_entry = Feedzirra::Parser::RSSEntry.new
        @feed_entry.url = 'http://www.unknown.url/gerhe'
        @feed_entry.content = 'We should get this.'
      end
      should("scrap content by the default scrapper") do
        assert_equal 'We should get this.', @feed_entry.scrap_content
      end
    end
  end

  context "on giving standard package of settings" do
    setup do
      @scrapper = ContentScrapper.new
      @scrapper.report_to_stderr
    end
    should "have the reporters set" do
      assert !@scrapper.scrapping_exception_handler_block.nil?
      assert !@scrapper.missing_url_matcher_handler_block.nil?
      assert !@scrapper.missing_content_handler_block.nil?
    end
  end
end

